
# Discovery

The discovery system provides a pluggable mechanism for nodes to discover peer nodes and verify their TLS identities. This decouples the cluster from specific infrastructure implementations and allows operators to provide discovery information that matches their environment.

## Overview

Each node in the cluster needs to know:
1. The network address (IP:port) of every other peer node
2. The expected identity (subject alternative name) in each peer's TLS certificate

The discovery system abstracts this information retrieval, supporting both static configurations and dynamic HTTP-based discovery.

## Discovery Modes

### Static Discovery

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

**File Fields:**
- `node_id`: Unique identifier matching the node's configured `node_id`
- `ip`: IP address or hostname of the node
- `identity`: TLS certificate verification information
  - `kind`: Type of identity check (`dns`, `ip`, or `spiffe`)
  - `value`: The expected value to match against the certificate's SAN

### HTTP Discovery

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
- **Path**: `/peers` (the endpoint is fixed)
- **Full URL**: `{discovery_http_host}/peers`
- **Headers**: None required

**HTTP Response Format:**
The endpoint must return a JSON response with the following structure:

```json
{
  "nodes": [
    {
      "node_id": "node1",
      "ip": "10.0.1.11",
      "identity": {
        "kind": "dns",
        "value": "node1.localhost"
      }
    },
    {
      "node_id": "node2",
      "ip": "10.0.1.12",
      "identity": {
        "kind": "dns",
        "value": "node2.localhost"
      }
    },
    {
      "node_id": "node3",
      "ip": "10.0.1.13",
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
  - `node_id` (string): Unique node identifier - should match node ids used in cluster
  - `ip` (string): IP address or hostname where the node listens for Raft traffic
  - `identity` (object): TLS certificate verification information
    - `kind` (string): Identity verification type: `dns`, `ip`, or `spiffe`
    - `value` (string): Expected value to match against the certificate

**Best Practices for HTTP Discovery Implementation:**

1. **Endpoint Requirements:**
   - Must be accessible from all cluster nodes
   - Should return the complete list of all nodes in the cluster
   - Should include the node's own entry

2. **Update Frequency:**
   - The system polls the endpoint periodically like every 2 seconds
   - Changes are detected and applied automatically

3. **Error Handling:**
   - If the endpoint is unreachable, the node continues with the last known peer list
   - HTTP errors (4xx, 5xx) are logged and the previous peer list is retained


## Identity Verification Types

The `identity` field specifies how to verify a peer's TLS certificate:

| Kind | Description | Value Example |
|------|-------------|---------------|
| `dns` | Verify against DNS Subject Alternative Name (SAN) | `node1.cluster.local` |
| `ip` | Verify against SAN by IP
| `spiffe` | Verify against SPIFFE ID | `spiffe://example.org/node1` |
