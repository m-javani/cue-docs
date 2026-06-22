# Deployment

## Docker

```dockerfile
FROM golang:1.21 AS builder
RUN go build -o cue ./cmd/cue

FROM alpine:latest
COPY --from=builder /cue /usr/local/bin/
EXPOSE 8321 8322 8323
ENTRYPOINT ["cue", "serve"]
```

## Kubernetes (StatefulSet)

See the example in the [Cue README](https://github.com/m-javani/cue/blob/main/README.md).

## Systemd

```ini
[Service]
ExecStart=/usr/local/bin/cue serve -config /etc/cue/config.yml
Restart=always
```

Recommended: Run **3, 5, or 7 nodes** for production.
