## Configuration

### Full Configuration Reference

```yaml
# Auto-generated if empty
proxy_id: "proxy-001"

api:
  host: "0.0.0.0"
  port: 8080
  websocket_read_buffer_size: 1024
  websocket_write_buffer_size: 1024
  read_timeout: "30s"
  write_timeout: "30s"
  idle_timeout: "120s"
  score_update_interval: "300ms"
  default_max_inflights: 10
  producer_req_buffer_size: 1000
  consumer_buffer_size: 1000
  max_jobs_per_topic: 10000

cluster:
  quic_addr: "0.0.0.0"
  quic_port: 8322
  cluster_seeds:
    - cue-node-1:8322
    - cue-node-2:8322
    - cue-node-3:8322
  heartbeat_interval: "1s"
  request_timeout: "30s"
  reconnect_delay: "5s"
  max_message_size: 1048576

auth:
  file: "config/auth.yml"
  reload_interval: "30s"

tls:
  cert_path: "certs/cert.pem"
  key_path: "certs/key.pem"
  ca_path: "certs/ca.pem"

address_resolver:
  type: static  # static, dns, service, exec
  config:
    port: 8322

tls_verifier:
  type: cn  # cn, dns, spiffe, exec
  config:
    domain: "cluster.local"
```

### Address Resolver Types

| Type | Description | Config |
|------|-------------|--------|
| `static` | Fixed list of node addresses | `peers: {node1: "192.168.1.10:8322"}` |
| `dns` | DNS SRV record resolution | `domain: "cue-cluster.local"` |
| `service` | Service discovery (Consul/Nomad) | TBD |
| `exec` | External script/command | TBD |

### TLS Verifier Types

| Type | Description | Config |
|------|-------------|--------|
| `cn` | Verify Common Name | None |
| `dns` | Verify DNS name | `domain: "cluster.local"` |
| `spiffe` | SPIFFE ID verification | `trust_domain: "example.org"` |
| `exec` | External verification | TBD |
