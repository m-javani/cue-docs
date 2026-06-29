# Quick Start

The fastest way to try Cue is with the **pre-packaged demo environment**.

## Download

[Download the demo zip here](../assets/demo/demo.zip)

```bash
cd demo
```

## Prerequisites

### docker & compose
- You need `docker` and `docker compose` installed on your machine

### websocat
- for consumer to open a WebSocket connection in terminal

```bash
# macOS
brew install websocat

# Linux (Ubuntu/Debian) - download binary
wget https://github.com/vi/websocat/releases/latest/download/websocat.x86_64-unknown-linux-musl -O websocat
chmod +x websocat
sudo mv websocat /usr/local/bin/

# Linux (Fedora/RHEL)
sudo dnf copr enable atim/websocat -y
sudo dnf install websocat
```

---

## Start the Demo

Everything is automated with a single command:

```bash
make start
```

This single command:
- Pulls `mehdyjavany/cue:latest` and `mehdyjavany/cue-proxy:latest` from Docker Hub
- Generates fresh TLS certificates
- Cleans old data
- Starts the cluster and proxy

**Expected output:**
```
✅ Cue Demo is ready!
API: http://localhost:8080
Health: make health
Logs: make logs
Stop: make stop
```

---

## Verify

```bash
make health
```

**Expected output:**
```
✅ Proxy healthy
✅ node1 healthy
✅ node2 healthy
✅ node3 healthy
```

---

## Try It Out

You'll need **two terminals** for this demo.

### Step 1: Terminal 1
- Create a Topic

```bash
make topic name=orders
```

**Expected output:**
```
{"status":"success"}
```

### Step 2: Terminal 1
- Subscribe as Consumer (WebSocket)

```bash
make subscribe topic=orders
```

This opens a WebSocket connection and waits for jobs.

**Expected output:**
```
{"action":"accepted","topic":"","jobId":"","seqId":0,"data":null}
```

### Step 3: Terminal 2
- Add Jobs

```bash
make job topic=orders payload='{"order_id": 1, "amount": 99.99}'
make job topic=orders payload='{"order_id": 2, "amount": 49.50}'
make job topic=orders payload='{"order_id": 3, "amount": 150.00}'
```

**Expected output:**
```
{"job_id":"job-1782218880-1598043","status":"success"}
```

### Watch the Consumer

In Terminal 1, you'll see jobs arriving in real-time:

```json
{"action":"accepted","topic":"","jobId":"","seqId":0,"data":null}
{"action":"job","topic":"orders","jobId":"job-1782218880-1598043","seqId":1,"data":{"order_id":1,"amount":99.99}}
{"action":"job","topic":"orders","jobId":"job-1782218892-1598362","seqId":2,"data":{"order_id":2,"amount":49.50}}
{"action":"job","topic":"orders","jobId":"job-1782218898-1598558","seqId":3,"data":{"order_id":3,"amount":150.00}}
```

---

## Stop All

```bash
make stop
```

This stops all containers and cleans up data.

---

## Makefile Commands

| Command | Description |
|---------|-------------|
| **Control** | |
| `make start` | Pull images, generate certs, start everything with fresh data |
| `make stop` | Stop all services and cleanup data |
| `make restart` | Stop and start fresh |
| `make logs` | View live logs |
| `make health` | Check health of all services |
| `make clean` | Remove everything (containers, data, certs) |
| **API** | |
| `make topic name=<topic>` | Create a new topic |
| `make job topic=<topic> payload='<json>'` | Add a job to a topic |
| `make subscribe topic=<topic>` | Subscribe as consumer (WebSocket) |

---

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check |
| `/metrics` | GET | Prometheus metrics |
| `/producer/topic` | POST | Create a topic |
| `/producer/job` | POST | Add a job |
| `/ws` | WebSocket | Subscribe as consumer |

---

## Examples

```bash
# Start the demo
make start

# Create a topic
make topic name=orders

# Add jobs
make job topic=orders payload='{"product":"book","quantity":1}'

# Subscribe to a topic
make subscribe topic=orders

# Check health
make health

# View logs
make logs

# Stop everything
make stop
```

---

## Notes

- Certificates and data are automatically cleaned on every `make start`
- No local build required - everything is pulled from Docker Hub
- All services are configured for HTTP (no TLS for API simplicity)
- Cluster communication uses TLS certificates generated automatically