# Authentication

Tokens are defined in `auth.yml`:

```yaml
tokens:
  - token: prod_token_123
    role: producer
  - token: cons_token_456
    role: consumer
  - token: admin_token_789
    role: admin
```

Roles: `producer`, `consumer`, `admin`, `monitoring`.

Tokens are automatically reloaded every 30 seconds.