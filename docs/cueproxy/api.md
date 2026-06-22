# API Reference

## Producer API

**Create Topic**
```http
POST /producer/topic
Authorization: Bearer <token>
{ "topic": "email-notifications" }
```

**Submit Job**
```http
POST /producer/job
Authorization: Bearer <token>
{
  "job": {
    "id": "job-123",
    "topic": "email-notifications",
    "data": "base64-encoded-payload"
  }
}
```

## Consumer WebSocket API

Connect to `ws://localhost:8080/ws?token=<consumer_token>`

See full message reference in the [CueProxy README](https://github.com/m-javani/cue-proxy).

---

