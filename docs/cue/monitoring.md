# Monitoring & Metrics (Cue Cluster)

Cue exposes detailed Prometheus metrics for both **partition-level** and **cluster-level** observability.

All metrics are available at `/metrics` on the Admin API port (default: `8321`).

---

## Partition Metrics (Per Topic)

These metrics use the `topic` label.

| Metric | Type | Description |
|--------|------|-----------|
| `cue_active_queue_depth{topic="..."}` | Gauge | Current number of jobs waiting to be dispatched |
| `cue_jobs_added_total{topic="..."}` | Counter | Total number of jobs added to the topic |
| `cue_jobs_completed_total{topic="..."}` | Counter | Total number of jobs successfully completed |
| `cue_jobs_retried_total{topic="..."}` | Counter | Total number of job retries |
| `cue_jobs_dead_letter_total{topic="..."}` | Counter | Total number of jobs moved to Dead Letter Queue |

---

## Cluster Metrics

| Metric | Type | Description |
|--------|------|-----------|
| `cluster_connection_opened_total` | Counter | Total connections opened |
| `cluster_connection_accepted_total` | Counter | Total connections accepted |
| `cluster_connection_rejected_total` | Counter | Total connections rejected |
| `cluster_connection_error_total` | Counter | Total connection errors |
| `cluster_connection_dropped_total` | Counter | Total connections dropped |
| `cluster_message_sent_total` | Counter | Total messages sent |
| `cluster_message_received_total` | Counter | Total messages received |
| `cluster_bytes_sent_total` | Counter | Total bytes sent |
| `cluster_bytes_received_total` | Counter | Total bytes received |
| `cluster_send_error_total` | Counter | Total send errors |
| `cluster_receive_error_total` | Counter | Total receive errors |
| `cluster_leader_changed_total` | Counter | Total leadership changes |
| `cluster_wal_flush_count_total` | Counter | Total WAL flushes |
| `cluster_last_applied_wal_index` | Gauge | Last applied WAL index |

---

## Gateway Metrics (to Proxies)

| Metric | Type | Description |
|--------|------|-----------|
| `cue_gateway_active_proxies` | Gauge | Number of currently connected CueProxy instances |
| `cue_gateway_active_connections` | Gauge | Number of active QUIC connections |
| `cue_gateway_messages_received_total` | Counter | Messages received from proxies |
| `cue_gateway_messages_sent_total` | Counter | Messages sent to proxies |
| `cue_gateway_connection_failures_total` | Counter | Failed connection attempts |
| `cue_gateway_network_errors_total` | Counter | Network errors (timeouts, resets, etc.) |

---

## Topic Manager Metrics

| Metric | Type | Description |
|--------|------|-----------|
| `cue_topic_manager_active_topics` | Gauge | Number of active topics |
| `cue_topic_manager_topics_created_total` | Counter | Total topics created |
| `cue_topic_manager_topics_removed_total` | Counter | Total topics removed |

---

**Health Check:**

```bash
curl http://localhost:8321/health
```

---

