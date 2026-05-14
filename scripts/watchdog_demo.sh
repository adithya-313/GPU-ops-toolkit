#!/bin/bash
# Demo watchdog with fast polling (3s) for stress test demo
while true; do
    usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)
    mem_pct=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null | head -1)
    mem_total=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1)
    mem_pct_calc=$(( mem_pct * 100 / mem_total ))
    if [ -z "$usage" ]; then echo "[ERROR] nvidia-smi failed"; exit 1; fi
    if [ "$usage" -gt 5 ] || [ "$mem_pct_calc" -gt 5 ]; then
        echo ""
        echo "!!! WARNING: GPU usage ${usage}%, Memory ${mem_pct_calc}% !!!"
    else
        echo "[$(date '+%H:%M:%S')] GPU: ${usage}%, Mem: ${mem_pct_calc}% - OK"
    fi
    sleep 3
done
