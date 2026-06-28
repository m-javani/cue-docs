## Configuration

### Full Configuration Reference

```yaml
# Auto-generated if empty
proxy_id: "proxy-001"

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
  auth_path: "config/auth.yml"
  # TLS settings for API (HTTP/WebSocket)
  tls_enabled: false  # Set to true to enable HTTPS
  cert_path: "certs/api-cert.pem"
  key_path: "certs/api-key.pem"
  ca_path: "certs/api-ca.pem"

cluster:
  quic_addr: "0.0.0.0"
  quic_port: 8322
  cluster_seeds:
    - cue-node-1:8322
    - cue-node-2:8322
    - cue-node-3:8322
  # TLS settings for Cluster (QUIC)
  cert_path: "certs/cluster-cert.pem"
  key_path: "certs/cluster-key.pem"
  ca_path: "certs/cluster-ca.pem"
  address_resolver:
    type: static  # static, dns, service
    config:
      port: 8322
      # For static resolver:
      # peers:
      #   cue-node-1: "192.168.1.10:8322"
      #   cue-node-2: "192.168.1.11:8322"
      # For dns resolver:
      # domain: "cue-cluster.local"
  tls_verifier:
    type: cn  # cn, dns, spiffe
    config:
      # For dns verifier:
      # domain: "cluster.local"
      # For spiffe verifier:
      # trust_domain: "example.org"
      # namespace: "default"  # optional
```

### Address Resolver Types

| Type | Description | Config |
|------|-------------|--------|
| `static` | Fixed list of node addresses | `peers: {node1: "192.168.1.10:8322"}` |
| `dns` | DNS SRV record resolution | `domain: "cue-cluster.local"` |
| `service` | Service discovery (Consul/Nomad) | TBD |

### TLS Verifier Types

| Type | Description | Config |
|------|-------------|--------|
| `cn` | Verify Common Name | None |
| `dns` | Verify DNS name | `domain: "cluster.local"` |
| `spiffe` | SPIFFE ID verification | `trust_domain: "example.org"` |
