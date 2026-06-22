# Limitations

- **In-memory only** — Jobs live in RAM (bounded by available memory)
- **No historical replay** — Acknowledged jobs are removed
- **Leader-dependent writes** — All submissions go through the current leader
- **Bounded capacity** — Configurable per-topic queue size
- **Not a streaming platform** — Use Kafka for large-scale persistent logs

**Cue is ideal for** reliable job dispatch with retries, not for event streaming or long-term storage.
