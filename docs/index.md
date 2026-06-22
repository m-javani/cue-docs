# Cue Documentation

**Cue** is a distributed, in-memory job queue with Raft-based consistency, automatic retries, and dead letter handling.

It is designed for teams that need **reliable job dispatch** without operating complex infrastructure like Kafka.

## Core Components

- **[Cue](./cue/overview.md)** — The distributed cluster (3/5/7 nodes)
- **[CueProxy](./cueproxy/overview.md)** — Stateless HTTP & WebSocket gateway

## Quick Links

- [Cue Quick Start](./cue/quickstart.md)
- [CueProxy Quick Start](./cueproxy/quickstart.md)
- [Cue GitHub](https://github.com/m-javani/cue)
- [CueProxy GitHub](https://github.com/m-javani/cue-proxy)

---

> **Cue is not a Kafka replacement.** It is a bounded, simple, and operationally light job queue.