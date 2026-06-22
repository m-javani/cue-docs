# Deployment

## Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: cueproxy
        image: cueproxy:latest
        ports:
        - containerPort: 8080
```

Place behind a LoadBalancer for horizontal scaling.