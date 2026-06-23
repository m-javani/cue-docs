# Cue Overview

**Cue** is a distributed, in-memory job queue with strong consistency via Raft.

## Architecture

![Cue Cluster Architecture with Multiple Proxies](../assets/images/leader-flow.png){: .cluster-diagram }

*Clients communicate with the cluster through proxies. The leader handles all writes, with Raft ensuring consistency across followers.*

---

## How It Works

### Data Model
- **Topics** are logical partitions for organizing jobs
- Each topic is an in-memory state machine
- Every node holds all topics - no sharding or data loss on leader failover
- **No snapshots** - state is fully in-memory (backed by WAL only)

### Write Path
1. Proxy sends request to leader's **Gateway**
2. Gateway forwards to **Cluster Agent**
3. Agent proposes to **Raft** for consensus
4. On commit, the **Router** directs to the correct **Partition**
5. Partition applies to state, response flows back to proxy

### Read/Dispatch Path
1. Each partition dispatches jobs to proxies using round-robin selection, with batch sizes proportional to each proxy's number of subscribed consumers for that topic
2. Jobs are sent back through **Gateway** to proxies
3. Proxies load-balance to subscribed consumers
4. Consumers ACK on completion → WAL truncation

---

## Key Concepts

### Raft Consensus
- **Strong consistency** - all writes go through the leader
- **Automatic failover** - on leader failure, a new leader is elected
- **Log replication** across followers ensures durability

### Write-Ahead Log (WAL)
- Segmented files for **durability**
- Truncated **periodically** up to the oldest safe index (all jobs ACK'd or DLQ'd)
- Result: **WAL size stays limited** - no unbounded growth

### Retries & Failure Handling
- **Automatic retries** with exponential backoff
- After max retries, jobs move to **Dead Letter Queue (DLQ)**
- DLQ jobs require manual inspection

---

## Component Overview

### Gateway
- QUIC server for **proxy communication**
- Own TLS certificate files (can be separate from cluster certs)

### Cluster Agent
- Manages **node-to-node** QUIC communication
- Can share gateway certs or use separate ones

### Raft Layer
- Core **consensus engine** with shared storage
- Decoupled from partitions

### Partitions & Router
- **Router** directs requests by topic
- **Partitions** are in-memory state machines for each topic

### API Server
- **Admin & control** REST API
- Health checks and Prometheus metrics

---

## Communication Matrix

| Component | Protocol | TLS |
|-----------|----------|-----|
| Gateway → Proxies | QUIC | Own certs |
| Cluster Agent → Nodes | QUIC | Shared/separate certs |
| API Server → Admin | HTTP/REST | Optional |

---

![Cue Cluster Architecture with Multiple Proxies](../assets/images/leader-components.png){: .cluster-diagram }

---
