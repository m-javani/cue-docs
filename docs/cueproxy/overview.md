# CueProxy Overview

**CueProxy** is the stateless HTTP and WebSocket gateway for Cue.

## Architecture

```mermaid
graph TD
    A[Producers] --> B[CueProxy Instances]
    C[Consumers] --> B
    B <--> D[Cue Cluster Leader]
    style B fill:#2196F3
```

- Completely stateless & horizontally scalable
- Handles authentication, load balancing, and backpressure
- Proxies communicate with Cue via QUIC

---

