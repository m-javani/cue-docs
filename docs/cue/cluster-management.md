# Cluster Management

## Health Check

```bash
curl http://localhost:8321/health
```

## Cluster Info

```bash
curl http://localhost:8321/cluster/info
```

## Administrative Operations

**Promote Learner**
```bash
curl -X POST http://localhost:8321/cluster/promote-learner \
  -H "Authorization: Bearer <admin_token>" \
  -d '{"node_id": "node4"}'
```

**Demote Voter / Remove Node**
```bash
curl -X POST http://localhost:8321/cluster/demote-voter \
  -H "Authorization: Bearer <admin_token>" \
  -d '{"node_id": "node2"}'
```

**Transfer Leadership**
```bash
curl -X POST http://localhost:8321/cluster/transfer-leader \
  -H "Authorization: Bearer <admin_token>" \
  -d '{"target_node_id": "node3"}'
```

All admin endpoints require a token with `admin` role.

---

