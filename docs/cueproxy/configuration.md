# Configuration

---

### Network Identity Resolution 

Proxies use each node's node_id as its network identity when establishing upstream connections (e.g., node1:8322), and this identifier should be treated as the canonical service identity for routing, service mesh registration, and discovery integration (Istio, Consul, etcd, etc.). If your infrastructure does not provide a service mesh or internal DNS resolution, the host field serves as the fallback network address; CueProxy prioritizes host when explicitly configured, otherwise defaults to resolving the upstream via its node_id.

---

### Full Configuration Reference

```yaml
api:
  host: "0.0.0.0"
  port: 8080
  read_timeout_sec: 45
  write_timeout_sec: 0
  idle_timeout_sec: 300
  ws_read_timeout_sec: 0
  ws_write_timeout_sec: 30
  ws_read_limit_bytes: 32768 # 32KB
  default_max_inflights: 10
  auth_path: "./auth.yml"
  tls_enabled: false  # Set to true to enable HTTPS for API
  cert_path: "certs/api-cert.pem"
  key_path: "certs/api-key.pem"

cluster:
  quic_addr: "0.0.0.0"
  quic_port: 8322
  cert_path: "certs/cluster-cert.pem"
  key_path: "certs/cluster-key.pem"
  ca_path: "certs/cluster-ca.pem"

  # Discovery configuration
  discovery_kind: "static"            # "static" or "http"
  discovery_yml_path: "./discovery.yml"  # Required for static discovery
  discovery_http_host: ""             # HTTP endpoint URL (required for http discovery)
                                      # Example: "http://discovery-service:8080"
```

---

### Discovery

The proxy uses the same discovery mechanism as Cue cluster nodes to locate peer nodes and verify their TLS identities. The discovery system is pluggable and supports two modes:

- **Static Discovery**: Reads peer information from a local YAML file
- **HTTP Discovery**: Queries an HTTP endpoint that you implement

The discovery configuration is specified under the `cluster` section in the config file:

```yaml
cluster:
  discovery_kind: "static"            # or "http"
  discovery_yml_path: "./discovery.yml"  # For static discovery
  discovery_http_host: "http://discovery-service:8080"  # For HTTP discovery
```

#### Static Discovery

Static discovery reads peer information from a local YAML file. This is suitable for fixed, known cluster topologies where node addresses and identities don't change.

**Configuration:**
```yaml
cluster:
  discovery_kind: "static"
  discovery_yml_path: "./discovery.yml"
```

**Discovery File Format (`discovery.yml`):**
```yaml
nodes:
  - node_id: node1
    host: 10.0.1.11
    identity:
      kind: dns
      value: node1.localhost

  - node_id: node2
    host: 10.0.1.12
    identity:
      kind: dns
      value: node2.localhost

  - node_id: node3
    host: 10.0.1.13
    identity:
      kind: dns
      value: node3.localhost
```

**File Fields:**
- `node_id`: Unique identifier matching the node's configured `node_id`
- `host`: IP address or hostname of the node
- `identity`: TLS certificate verification information
  - `kind`: Type of identity check (`dns`, `ip`, or `spiffe`)
  - `value`: The expected value to match against the certificate's SAN

#### HTTP Discovery

HTTP discovery queries an external HTTP endpoint that you implement. This is ideal for dynamic environments where:
- Nodes come and go (auto-scaling)
- IP addresses change frequently (cloud environments)
- TLS certificates are dynamically issued
- You want to centralize cluster membership information

**Configuration:**
```yaml
cluster:
  discovery_kind: "http"
  discovery_http_host: "http://discovery-service:8080"
```

**HTTP Request:**
- **Method**: GET
- **Path**: `/peers`
- **Query String**: `?client=cueproxy` (the proxy always sends this)
- **Full URL**: `{discovery_http_host}/peers?client=cueproxy`
- **Headers**: None required

**HTTP Response Format:**
The endpoint must return a JSON response with the following structure:

```json
{
  "nodes": [
    {
      "node_id": "node1",
      "host": "10.0.1.11",
      "identity": {
        "kind": "dns",
        "value": "node1.localhost"
      }
    },
    {
      "node_id": "node2",
      "host": "10.0.1.12",
      "identity": {
        "kind": "dns",
        "value": "node2.localhost"
      }
    },
    {
      "node_id": "node3",
      "host": "10.0.1.13",
      "identity": {
        "kind": "dns",
        "value": "node3.localhost"
      }
    }
  ]
}
```

**Response Fields:**
- `nodes` (array): List of known nodes in the cluster
  - `node_id` (string): Unique node identifier — should match node ids used in cluster
  - `host` (string): IP address or hostname where the node listens for cluster traffic
  - `identity` (object): TLS certificate verification information
    - `kind` (string): Identity verification type: `dns`, `ip`, or `spiffe`
    - `value` (string): Expected value to match against the certificate

**Client-Specific Views:**
The discovery endpoint receives a `client` query parameter indicating the requester:
- `?client=cue` — Cue cluster nodes
- `?client=cueproxy` — CueProxy instances

The endpoint may return different `host` values for each client. For example, Cue nodes may use internal network addresses (e.g., `10.0.1.11`), while proxies may need externally routable addresses (e.g., `node1.public.example.com`). The identity verification (`kind` and `value`) typically remains the same.

**Best Practices for HTTP Discovery Implementation:**

1. **Endpoint Requirements:**
   - Must be accessible from all proxy instances
   - Should return the complete list of all nodes in the cluster
   - Should include each node's own entry

2. **Update Frequency:**
   - The system polls the endpoint periodically (approximately every 2 seconds)
   - Changes are detected and applied automatically

3. **Error Handling:**
   - If the endpoint is unreachable, the proxy continues with the last known peer list
   - HTTP errors (4xx, 5xx) are logged and the previous peer list is retained

---

### Identity Verification Types

The `identity` field specifies how to verify a peer's TLS certificate:

| Kind | Description | Value Example |
|------|-------------|---------------|
| `dns` | Verify against DNS Subject Alternative Name (SAN) | `node1.cluster.local` |
| `ip` | Verify against SAN by IP | `10.0.1.11` |
| `spiffe` | Verify against SPIFFE ID | `spiffe://example.org/node1` |