#!/usr/bin/env python3
# WARNING: This script is designed to trigger the watchdog and will be killed.

import torch

if not torch.cuda.is_available():
    print("No GPU detected — cannot run stress test.")
    exit(1)

print("GPU Stress Test — pushing utilization past the 90% kill zone")
print("============================================================")
step = 0

# Accumulate tensors to fill memory AND do compute to drive utilization
tensors = []

while True:
    step += 1
    x = torch.randn(10000, 10000).cuda()
    y = torch.randn(10000, 10000).cuda()
    z = x @ y                     # Matrix multiply: drives compute %
    tensors.append(x)              # Keep x to grow memory usage
    del y, z
    used = torch.cuda.memory_allocated(0) / 1024**3
    total = torch.cuda.get_device_properties(0).total_memory / 1024**3
    pct = (used / total) * 100
    print(f"  Step {step}: {used:.2f} GB / {total:.2f} GB ({pct:.1f}%)")
