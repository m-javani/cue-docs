# Configuration

## Full Configuration Reference

```yaml
node_id: "node1"
data_dir: "./data/node1"

cluster:
  listen_addr: "0.0.0.0"
  quic_port: 8323
  cert_path: "./certs/node1.pem"
  key_path: "./certs/node1_key.pem"
  ca_path: "./certs/ca_cert.pem"
  initial_voters: ["node1", "node2", "node3"]
  peers: ["node1", "node2", "node3"]

proxy:
  addr: "0.0.0.0"
  port: 8322
  cert_path: "./certs/node1.pem"
  key_path: "./certs/node1_key.pem"
  ca_path: "./certs/ca_cert.pem"

api:
  listen_addr: "0.0.0.0"
  api_port: 8321
  token_path: "./configs/auth.yml"

partition:
  active_queue_capacity: 1000000
  retry_base_delay_ms: 1000
  max_retries: 3
  max_backoff_ms: 60000

wal:
  compact_after_bytes: 104857600
```

See the [Cue README](https://github.com/m-javani/cue) for all available options and address resolver types.
```
