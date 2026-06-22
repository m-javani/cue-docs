# Monitoring

Cue exposes Prometheus metrics at `/metrics`.

### Important Metrics

- `cue_active_queue_depth{topic="..."}`
- `cue_jobs_added_total{topic="..."}`
- `cue_jobs_completed_total`
- `cue_jobs_retried_total`
- `cue_jobs_dead_letter_total`
- `cluster_leader_changed_total`

### Prometheus Scrape Config

```yaml
scrape_configs:
  - job_name: 'cue-cluster'
    static_configs:
      - targets: ['node1:8321', 'node2:8321', 'node3:8321']
```

See the full list in the [Cue repository](https://github.com/m-javani/cue).