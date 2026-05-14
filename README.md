# 🚀 GPU Ops Toolkit

> **A containerized, self-healing GPU monitoring suite designed for high-availability MLOps environments.**

![Status: Complete](https://img.shields.io/badge/Status-Complete-success)
![Python 3.x](https://img.shields.io/badge/Python-3.x-blue)
![Docker](https://img.shields.io/badge/Docker-Supported-2496ED)

The GPU Ops Toolkit is a production-readiness bridge between raw AI development and stable system operations. It transforms a standard GPU machine into a monitored, self-healing environment ready for load-balanced traffic.

## 🧠 Core Features

* **Hardware-Software Sync:** Validates NVIDIA drivers, CUDA, and PyTorch versions.
* **Real-Time Observability:** Extracts memory, utilization, and thermals to CSV for dashboarding.
* **Self-Healing Watchdog:** Automatically kills runaway PyTorch processes that exceed 90% memory utilization.
* **Chaos Engineering:** Includes stress-testing tools to validate system limits.
* **Cloud Ready:** Containerized via Docker and features a FastAPI health-check endpoint for Layer-7 Load Balancers.

---

## 🏗️ System Architecture
*For the full load-balanced 3-server architecture, see [`docs/architecture.md`](docs/architecture.md).*

---

## ⚙️ Quick Start (Docker)

The easiest way to deploy the toolkit and the Load Balancer Health API is via Docker:

```bash
# Build the image
docker build -t gpu-ops-toolkit .

# Run the container (exposes Health API on port 8000)
docker run --gpus all -p 8000:8000 gpu-ops-toolkit
```
*You can now point your load balancer to `http://localhost:8000/health`*

---

## 🛠️ Manual Usage & Modules

If running bare-metal, use the following modules:

### 1. Stack Validation
Checks for driver mismatches and CUDA availability.
```bash
bash scripts/verify_stack.sh
```

### 2. Memory Profiler
Profiles a PyTorch tensor allocation to monitor VRAM spikes.
```bash
python3 src/memory_profile.py
```

### 3. The Watchdog (Self-Healing)
Polls the GPU every 30s. If usage > 90%, it kills the offending PID.
```bash
bash scripts/monitor_watchdog.sh
```

### 4. Metrics Extraction
Exports current GPU thermals, usage, and memory to `gpu_metrics.csv`.
```bash
bash scripts/query_metrics.sh
```

### 5. Chaos Stress Test
Intentionally floods the GPU memory to trigger and verify the Watchdog.
```bash
python3 scripts/stress_test.py
```
