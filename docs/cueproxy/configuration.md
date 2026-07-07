# Configuration

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
  discovery_yml_path: "./discovery.yml"  # Bootstrap discovery file
  cluster_api_port: 8321  # Port for cluster API (topology updates)
```

### Discovery

The proxy uses a discovery file to bootstrap its connection to the cluster. At startup, it reads the discovery file to locate at least one active cluster node and perform TLS verification. The file follows the same format as the Cue cluster discovery:

```yaml
nodes:
  - node_id: node1
    ip: 10.0.1.11
    identity:
      kind: dns
      value: node1.localhost

  - node_id: node2
    ip: 10.0.1.12
    identity:
      kind: dns
      value: node2.localhost

  - node_id: node3
    ip: 10.0.1.13
    identity:
      kind: dns
      value: node3.localhost
```

**Discovery Fields:**
- `node_id`: Node identifier matching the cluster seed names
- `ip`: IP address or hostname of the cluster node
- `identity`: TLS certificate verification information
  - `kind`: Identity verification type: `dns`, `ip`, or `spiffe`
  - `value`: Expected value to match against the certificate's SAN

**Bootstrap Process:**
1. Proxy reads `discovery_yml_path` at startup
2. Attempts to connect to nodes listed in the discovery file (in order)
3. Verifies each node's TLS certificate matches the specified identity
4. Once connected, establishes QUIC communication with the cluster

**Topology Awareness:**
After initial connection, the proxy receives topology updates from the cluster leader. When the cluster topology changes (nodes added/removed), the leader pushes updates to connected proxies. Proxies then fetch the complete discovery list from the leader's API endpoint (port `cluster_api_port`) to stay synchronized with the current cluster state. This ensures proxies are always topology-aware without requiring external HTTP discovery endpoints.

**Note:** At least one node in the discovery file must be reachable and active for the proxy to bootstrap successfully.

---