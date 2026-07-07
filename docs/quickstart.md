# Cue Quick Start

**Prerequisites**

- Docker and Docker Compose installed
- Python 3 installed
- Install WebSocket library (one time):
  ```bash
  pip3 install websockets
  ```

---

The fastest way to try Cue is with the **pre-packaged demo environment**.

## Download

[Download the demo zip here](../assets/demo/demo.zip)

```bash
cd demo
```

---

## 1. Start the Demo

```bash
make start
```

---

## 2. Try It Out

Open **two terminals**:

### Terminal 1 — Create Topic + Consumer

```bash
# Create topic first
make topic name=orders

# Then start consumer
make consumer topic=orders
```

> **Important:** Create the topic and start the consumer **before** sending jobs. Otherwise, jobs may be retried or dropped.

### Terminal 2 — Send Jobs

```bash
make job topic=orders payload='{"order_id": 1, "amount": 99.99}'
make job topic=orders payload='{"order_id": 2, "amount": 49.50}'
```

You will see the jobs arriving in real-time in Terminal 1.

---


## 3. Stop the containers

```bash
make stop
```

---

## Useful Commands

```bash
make start      # Start fresh demo
make stop       # Stop everything
make logs       # View logs
make health     # Check status

make topic name=xxx
make consumer topic=xxx
make job topic=xxx payload='{...}'
```

**Note:** Always create the topic **before** starting the consumer.