#!/bin/bash
# verify_stack.sh - Check if GPU drivers and libraries are properly installed

echo "========================================"
echo "  GPU Stack Verification Script"
echo "========================================"

# Section 1: Check nvidia-smi
echo ""
echo "[1/3] Checking NVIDIA Driver with nvidia-smi..."
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=driver_version --format=csv,noheader
else
    echo "  WARNING: nvidia-smi not found. NVIDIA drivers may not be installed."
fi

# Section 2: Check CUDA availability in PyTorch
echo ""
echo "[2/3] Checking PyTorch CUDA availability..."
python3 -c "import torch; print('  CUDA Available:', torch.cuda.is_available()); print('  GPU Count:', torch.cuda.device_count() if torch.cuda.is_available() else 0)"

# Section 3: Print version info
echo ""
echo "[3/3] Environment summary:"
python3 --version 2>/dev/null || echo "  Python3 not found"
nvcc --version 2>/dev/null || echo "  nvcc not found (CUDA toolkit may not be installed)"

echo ""
echo "========================================"
echo "  Verification complete."
echo "========================================"
