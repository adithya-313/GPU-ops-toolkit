#!/usr/bin/env python3
"""
memory_profile.py - Show GPU memory usage change when loading a model/tensor.

Usage:
    python memory_profile.py
"""

import torch

def print_gpu_memory(label: str) -> None:
    """Print current GPU memory usage with a descriptive label."""
    total_gpu_memory = torch.cuda.get_device_properties(0).total_memory
    reserved_memory = torch.cuda.memory_reserved(0)
    allocated_memory = torch.cuda.memory_allocated(0)

    print(f"  [{label}]")
    print(f"    Total GPU memory:  {total_gpu_memory / 1024**3:.2f} GB")
    print(f"    Reserved memory:   {reserved_memory / 1024**3:.2f} GB")
    print(f"    Allocated memory:  {allocated_memory / 1024**3:.2f} GB")


def main() -> None:
    if not torch.cuda.is_available():
        print("No CUDA-capable GPU detected. Cannot run memory profile.")
        print("Simulated Output (what a user with a GPU would see):")
        print("")
        print("  [Before loading tensor]")
        print("    Total GPU memory:  23.99 GB")
        print("    Reserved memory:   0.00 GB")
        print("    Allocated memory:  0.00 GB")
        print("")
        print("  Loading tensor: x = torch.randn(10000, 10000).cuda() ...")
        print("")
        print("  [After loading tensor]")
        print("    Total GPU memory:  23.99 GB")
        print("    Reserved memory:   0.76 GB")
        print("    Allocated memory:  0.38 GB")
        return

    print("GPU Memory Profile")
    print("==================")
    print("")

    # Snapshot before allocation
    print_gpu_memory("Before loading tensor")

    # Allocate a large tensor on GPU
    print("")
    print("  Loading tensor: x = torch.randn(10000, 10000).cuda() ...")
    x = torch.randn(10000, 10000).cuda()
    print("  Done.")
    print("")

    # Snapshot after allocation
    print_gpu_memory("After loading tensor")

    # Cleanup
    del x
    torch.cuda.empty_cache()


if __name__ == "__main__":
    main()
