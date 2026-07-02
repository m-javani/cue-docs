# Benchmarking CUE

The CUE benchmark tool measures end-to-end system throughput in two phases:

1. **Ingestion** - How fast the system accepts jobs from producers
2. **Dispatch** - How fast the system delivers jobs to consumers

This is a throughput test, not a tail-latency micro-benchmark.

## Repository

All benchmark code, configuration, and documentation lives in its own repository:

➡️ **[github.com/m-javani/cue-benchmark](https://github.com/m-javani/cue-benchmark)**

## Quick Example

```bash
# Clone and run
git clone https://github.com/m-javani/cue-benchmark
cd cue-benchmark

# Basic benchmark (requires cluster + proxy running)
go run main.go -topics 4 -consumers 200 -jobs 4000
```

For full usage, flags, and tuning guidance, see the repository README.

