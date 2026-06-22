# Quick Start

1. Start a Cue cluster first
2. Create `config.yml`
3. Create `auth.yml`
4. Run CueProxy

```bash
./cueproxy -config config.yml
```

Then test:

```bash
curl http://localhost:8080/health
```