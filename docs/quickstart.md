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

## start all

```bash
make all
```

This single command:
- Clones the source repositories
- Builds the binaries
- Builds Docker images
- Generates TLS certificates
- Starts the cluster and proxy

**Expected output:**
```
✅ All services started!
API: http://localhost:8080
Health: curl http://localhost:8080/health
```

---

## verify

```bash
make health
```

**Expected output:**
```
✅ node1 healthy
✅ node2 healthy
✅ node3 healthy
```

---

## Try It Out

You'll need **two terminals** for this demo.

### Step 1: Terminal 1
- Create a Topic (http)

```bash
make topic name=orders
```

**Expected output:**
```
Creating topic: orders
{"status":"success"}
```

### Step 2: Terminal 1
- Subscribe as Consumer (websocket)

```bash
make subscribe topic=orders
```

This opens a WebSocket connection and waits for jobs.

**Expected output:**
```
Connecting to topic: orders (UUID: consumer-yourname)
{"action":"accepted","topic":"","jobId":"","seqId":0,"data":null}
```

### Step 3: Terminal 2
 - Add Jobs (http)

```bash
make job topic=orders payload='{"order_id": 1, "amount": 99.99}'
make job topic=orders payload='{"order_id": 2, "amount": 49.50}'
make job topic=orders payload='{"order_id": 3, "amount": 150.00}'
```

**Expected output:**
```
Adding job to topic: orders (ID: job-1782218880-1598043)
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

---

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make all` | Clone repos, build binaries, generate certs, and start everything |
| `make start` | Start services (certs must already exist) |
| `make stop` | Stop all services |
| `make health` | Check health of all services |
| `make topic name=<topic>` | Create a new topic |
| `make job topic=<topic> payload='<json>'` | Add a job to a topic |
| `make subscribe topic=<topic>` | Subscribe as consumer (WebSocket) |
| `make logs` | View live logs |
| `make clean` | Stop and remove everything |

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
