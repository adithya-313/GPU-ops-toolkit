#!/bin/bash
# monitor_watchdog.sh - Watchdog guard that monitors GPU usage and warns on high load

echo "========================================"
echo "  GPU Watchdog Monitor"
echo "  Press Ctrl+C to stop."
echo "========================================"

# Loop forever; sleep inside controls the polling interval
while true; do
    # Get the current GPU memory usage percentage (first GPU, index 0)
    usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)

    # If nvidia-smi failed, exit gracefully
    if [ -z "$usage" ]; then
        echo "[ERROR] Unable to query GPU. Is nvidia-smi working?"
        exit 1
    fi

    # Check if memory usage exceeds the 90% threshold
    if [ "$usage" -gt 90 ]; then
        # Print a bold WARNING when usage is critical
        echo ""
        echo "!!! WARNING: GPU usage is at ${usage}% !!!"
        echo "Processes currently using the GPU:"
        nvidia-smi --query-compute-apps=pid,name,used_memory --format=csv,noheader 2>/dev/null

        # Safety: commented out — uncomment with caution
        # echo "Attempting to kill the top consumer..."
        # kill -9 $(nvidia-smi --query-compute-apps=pid --format=csv,noheader 2>/dev/null | head -1)
    else
        # Normal status update
        echo "[$(date '+%H:%M:%S')] GPU usage: ${usage}% - OK"
    fi

    # Wait 30 seconds before the next check
    sleep 30
done
