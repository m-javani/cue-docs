# Configuration

### Full Configuration Reference

```yaml
# Node identity
node_id: "node1"                      # Unique identifier
data_dir: "./data"                    # Data directory for Raft and WAL

# Cluster (internal Raft communication)
cluster:
  listen_addr: "0.0.0.0"              # Listen address
  quic_port: 8323                     # QUIC port for cluster communication
  cert_path: "./certs/node1.pem"      # TLS certificate
  key_path: "./certs/node1_key.pem"   # TLS private key
  ca_path: "./certs/ca_cert.pem"      # CA certificate for mTLS
  initial_voters: ["node1","node2","node3"]  # Initial Raft voters
  peers: ["node1","node2","node3"]    # Peer nodes for discovery
  snapshot_interval_sec: 60           # Snapshot interval in seconds
  snapshot_trigger_count: 10000       # Snapshot trigger entry count
  wal_flush_threshold: 1000           # WAL flush threshold
  dlq_max_size_bytes: 10485760        # Max DLQ size (10MB)
  raft_tick_ms: 100                   # Raft tick interval (100ms)
  raft_heartbeat_tick: 5              # Heartbeat tick multiplier (500ms)
  raft_election_tick: 50              # Election tick multiplier (5s)

# Proxy (external CueProxy communication)
proxy:
  addr: "0.0.0.0"                     # Listen address
  port: 8322                          # QUIC port for proxies
  cert_path: "./certs/node1.pem"      # TLS certificate
  key_path: "./certs/node1_key.pem"   # TLS private key
  ca_path: "./certs/ca_cert.pem"      # CA certificate

# Admin API
api:
  listen_addr: "0.0.0.0"              # Listen address
  api_port: 8321                      # HTTP API port
  token_path: "./configs/auth.yml"    # Token file path
  timeout_seconds: 10                 # Request timeout

# Write-Ahead Log
wal:
  compact_after_bytes: 104857600      # Compact WAL after 100MB
  sync_interval: "1s"                 # WAL sync interval

# Partition settings
partition:
  active_queue_capacity: 1000000      # Max jobs per partition
  retry_base_delay_ms: 1000           # Initial retry delay (1s)
  max_retries: 3                      # Max retry attempts
  max_backoff_ms: 60000               # Max backoff (60s)
  dispatch_batch_size: 128            # Batch size for dispatch
  dlq_max_bytes: 10485760             # DLQ max size (10MB)
  dlq_max_age_ms: 86400000            # DLQ max age (24 hours)

# Logging
logging:
  level: "info"                       # debug, info, warn, error
  format: "json"                      # json or text
  output_path: "stdout"               # stdout, stderr, or file path

# Service discovery
address_resolver:
  type: static                        # static, dns, service, exec
  config:
    peers:                            # For static resolver
      node1: "192.168.1.10:8323"
      node2: "192.168.1.11:8323"
      node3: "192.168.1.12:8323"
    # domain: "cluster.local"         # For DNS resolver
    # port: 8323

# TLS verification
tls_verifier:
  type: cn                            # cn, dns, spiffe, exec
  # config:
  #   domain: "cluster.local"         # For DNS verifier
  #   trust_domain: "example.org"     # For SPIFFE verifier
```

### Address Resolver Types

| Type | Description | Config |
|------|-------------|--------|
| `static` | Fixed mapping of node IDs to addresses | `peers: {node1: "192.168.1.10:8323"}` |
| `dns` | DNS SRV record resolution | `domain: "cue-cluster.local"` |
| `service` | Service discovery (Consul/Nomad) | None needed |
| `exec` | External script/command | TBD |

### TLS Verifier Types

| Type | Description | Config |
|------|-------------|--------|
| `cn` | Verify Common Name matches node ID | None |
| `dns` | Verify DNS name | `domain: "cluster.local"` |
| `spiffe` | SPIFFE ID verification | `trust_domain: "example.org"` |
| `exec` | External verification | TBD |
