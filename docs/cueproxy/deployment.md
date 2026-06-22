## Deployment

### Docker

The project includes a **production-ready multi-stage Dockerfile**.

#### Build the image

```bash
docker build -t cue:latest .
```

#### Run 

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

  ---