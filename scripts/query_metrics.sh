#!/bin/bash
# query_metrics.sh - Capture GPU stats as clean CSV for data analysis

# The flags --noheader and --nounits make the output purely numeric,
# so a computer can parse it easily (no "MiB" or "%" strings to strip).
nvidia-smi --query-gpu=utilization.gpu,memory.used,temperature.gpu --format=csv,noheader,nounits | tee gpu_stats.csv
