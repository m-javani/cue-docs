# Monitoring & Metrics (CueProxy)

CueProxy exposes Prometheus metrics at the `/metrics` endpoint (default port: `8080`).

---

## HTTP & API Metrics

| Metric | Type | Description |
|--------|------|-----------|
| `proxy_http_requests_total{method, endpoint, status}` | CounterVec | Total HTTP requests (broken down by method, endpoint, and status code) |
| `proxy_http_request_duration_seconds{method, endpoint}` | Histogram | HTTP request latency distribution |

---

## WebSocket Metrics

| Metric | Type | Description |
|--------|------|-----------|
| `proxy_websocket_connections` | Gauge | Current number of active WebSocket consumer connections |

---

## Job Delivery Metrics (Per Topic)

| Metric | Type | Description |
|--------|------|-----------|
| `proxy_jobs_pushed_per_topic{topic}` | CounterVec | Total jobs pushed to consumers for a topic |
| `proxy_jobs_acked_per_topic{topic}` | CounterVec | Total jobs acknowledged by consumers |
| `proxy_jobs_dropped_per_topic{topic}` | CounterVec | Total jobs dropped (e.g. due to backpressure or consumer disconnect) |

---

## Authentication Metrics

| Metric | Type | Description |
|--------|------|-----------|
| `proxy_auth_failures_total` | Counter | Total authentication and authorization failures |

---

**Health Check:**

```bash
curl http://localhost:8080/health
```

---