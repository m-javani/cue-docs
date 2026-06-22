# Configuration

```yaml
api:
  host: "0.0.0.0"
  port: 8080
  default_max_inflights: 10

cluster:
  cluster_seeds:
    - cue-node-1:8322
    - cue-node-2:8322

auth:
  file: "config/auth.yml"

tls:
  cert_path: "certs/cert.pem"
  key_path: "certs/key.pem"
```

Full options are available in the [CueProxy README](https://github.com/m-javani/cue-proxy).