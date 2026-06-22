
## Authentication

Authentication tokens are stored in a YAML file with automatic reloading every 30 seconds.

```yaml
# config/auth.yml
tokens:
  - token: prod_abc123
    role: producer
  - token: cons_xyz789
    role: consumer
  - token: admin_2024
    role: admin
  - token: mon_123
    role: monitoring
```

**Roles:**
- `producer`: Can create topics and submit jobs
- `consumer`: Can connect via WebSocket to consume jobs
- `admin`: Can perform all operations
- `monitoring`: Can access metrics endpoint

Tokens are sent via:
- HTTP Header: `Authorization: Bearer <token>`
- Query Parameter: `?token=<token>` (primarily for WebSocket)

> **Security Note:** Production deployments should use HTTPS/WSS to protect tokens in transit.
