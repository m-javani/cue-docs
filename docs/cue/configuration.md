# Configuration

---

### Network Identity Resolution 
Nodes use their own node_id as their network identity when establishing connections to peers (e.g., node1:8323), and this identifier should be treated as the canonical service identity for routing, service mesh registration, and discovery integration (Istio, Consul, etcd, etc.). If your infrastructure does not provide a service mesh or internal DNS resolution, the host field serves as the fallback network address; Cue nodes prioritize host when explicitly configured, otherwise default to resolving the peer via its node_id.

---

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
  snapshot_interval_sec: 60           # Snapshot interval in seconds
  snapshot_trigger_count: 10000       # Snapshot trigger entry count
  wal_flush_threshold: 1000           # WAL flush threshold
  dlq_max_size_bytes: 10485760        # Max DLQ size (10MB)
  raft_tick_ms: 100                   # Raft tick interval (100ms)
  raft_heartbeat_tick: 3              # Heartbeat tick multiplier (300ms)
  raft_election_tick: 30              # Election tick multiplier (3s)
  
  # Discovery configuration
  discovery_kind: "static"            # "static" or "http"
  discovery_yml_path: "./discovery.yml"  # Required for static discovery
  discovery_http_host: ""             # HTTP endpoint URL (required for http discovery)
                                      # Example: "http://discovery-service:8080"

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
  max_retries: 3                      # Max retry attempts
  max_backoff_sec: 2                  # Maximum backoff in seconds
  dispatch_batch_size: 128            # Batch size for dispatch
  dlq_max_bytes: 10485760             # DLQ max size (10MB)
  dlq_max_age_ms: 86400000            # DLQ max age (24 hours)

# Logging
logging:
  level: "info"                       # debug, info, warn, error
  format: "json"                      # json or text
  output_path: "stdout"               # stdout, stderr, or file path
```

---

### Discovery Configuration

The cluster uses a discovery mechanism to locate peer nodes and verify their identities. The discovery system is pluggable and supports two modes:

- **Static Discovery**: Reads peer information from a local YAML file
- **HTTP Discovery**: Queries an HTTP endpoint that you implement based on your infrastructure

The discovery configuration is specified under the `cluster` section in config yaml file:

```yaml
cluster:
  discovery_kind: "static"            # or "http"
  discovery_yml_path: "./discovery.yml"  # For static discovery
  discovery_http_host: "http://discovery-service:8080"  # For HTTP discovery
```

For detailed information about the discovery protocol, file format, and HTTP API specification, see the [Discovery](./discovery.md) page.

---
