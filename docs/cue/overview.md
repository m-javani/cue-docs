# Cue Overview

**Cue** is a distributed, in-memory job queue with strong consistency via Raft.

## Architecture

```mermaid
graph TD
    A[Producers] --> B[CueProxy]
    C[Consumers] --> B
    B <--> D[Cue Cluster - Leader]
    D <--> E[Follower 1]
    D <--> F[Follower 2]
    style D fill:#4CAF50,stroke:#333
```

### Key Concepts

- Every node holds all partitions (topics) in memory
- Raft ensures linearizable consistency across the cluster
- Write-Ahead Log (WAL) for durability
- Automatic retries with exponential backoff
- Dead Letter Queue (DLQ) for failed jobs

**CueProxy** acts as the stateless gateway for external communication.

---