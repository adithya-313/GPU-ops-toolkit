# GPU-ops-toolkit

A lightweight GPU monitoring, profiling, and operations toolkit built for developers and ops engineers managing GPU infrastructure.

---

## Scripts Overview

### 1. Stack Verification — `scripts/verify_stack.sh`

Checks whether the GPU drivers, CUDA toolkit, and PyTorch CUDA bindings are installed and compatible.

```bash
bash scripts/verify_stack.sh
```

### 2. Memory Profiler — `src/memory_profile.py`

Profiles GPU memory usage before and after allocating a large tensor. Useful for understanding memory consumption patterns.

```bash
python src/memory_profile.py
```

### 3. CSV Metrics Query — `scripts/query_metrics.sh`

Captures real-time GPU utilisation, memory usage, and temperature as a clean CSV row (numbers only) for logging and analysis.

```bash
bash scripts/query_metrics.sh
```

Output is printed to console and saved to `gpu_stats.csv`.

### 4. Watchdog Monitor — `scripts/monitor_watchdog.sh`

Runs an infinite loop that polls GPU utilisation every 30 seconds and warns when usage exceeds 90%.

```bash
bash scripts/monitor_watchdog.sh
```

Press `Ctrl+C` to stop.

---

## System Design: 3-Server Load-Balanced Architecture

The toolkit is designed to support a production GPU inference pipeline with three dedicated GPU servers behind a single load balancer.

### Architecture Diagram

```
        ┌──────────────┐
        │    User      │
        │  (Client)    │
        └──────┬───────┘
               │
               ▼
        ┌──────────────┐
        │   Load       │
        │   Balancer   │
        │ (Round Robin)│
        └──┬────┬────┬─┘
           │    │    │
     ┌─────▼┐ ┌▼────┐ ┌▼─────┐
     │GPU   │ │GPU  │ │GPU   │
     │Server│ │Server│ │Server│
     │  1   │ │  2   │ │  3   │
     └──────┘ └──────┘ └──────┘
```

### Request Flow

1. A **User** sends an inference or training request to the system endpoint.
2. The **Load Balancer** receives the request and forwards it to one of three GPU servers using a round-robin strategy.
3. The selected **GPU Server** processes the request using its local NVIDIA GPU and returns the result through the load balancer back to the user.

This design ensures horizontal scalability, fault tolerance (if one server fails, the balancer routes to the remaining two), and efficient resource utilisation across the GPU cluster.

---

## Advanced Features

### 5. Chaos Stress Test — `scripts/stress_test.py`

Intentionally fills GPU memory in a loop to trigger the watchdog monitor and verify crash recovery.

```bash
python scripts/stress_test.py
```

**Caution:** This will be killed by the watchdog once memory crosses 90%.

### 6. Health API — `src/health_api.py`

A FastAPI server exposing a `/health` endpoint for load balancer health checks. Returns GPU detection status.

```bash
pip install fastapi uvicorn
uvicorn src.health_api:app --host 0.0.0.0 --port 8000
```

```bash
curl http://localhost:8000/health
# {"status":"healthy","gpu":"detected"}
```

### 7. Docker Support — `Dockerfile`

Containerise the entire toolkit with a single build:

```bash
docker build -t gpu-ops-toolkit .
docker run -p 8000:8000 --gpus all gpu-ops-toolkit
```

---

## Project Status

| Goal | Status |
|---|---|
| Stack verification script | Complete |
| Python memory profiler | Complete |
| Watchdog monitor guard | Complete |
| CSV metrics extraction | Complete |
| System architecture documentation | Complete |
