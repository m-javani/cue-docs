# Deployment

## Docker

The official Dockerfile is located in the repository root.

```bash
docker build -t cue:latest .
```
### Run the container
```bash
docker run -d \
  --name cue-node1 \
  -p 8321:8321 \
  -p 8322:8322 \
  -p 8323:8323 \
  -v ./data/node1:/data \
  cue:latest \
  serve -config /etc/cue/config.yml
```

Recommended: Run **3, 5, or 7 nodes** for production.

---

