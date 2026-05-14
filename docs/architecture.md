# System Architecture: GPU Ops Toolkit

This document outlines the production request flow and the integration of the GPU Ops Toolkit across a load-balanced 3-server cluster.

## Request Flow Diagram

```mermaid
graph TD
    %% Define Client and Entry Point
    Client([Client / End User])
    DNS[DNS / Route53]
    LB[[Layer 7 Load Balancer<br/>Nginx / HAProxy]]

    %% Define the servers
    subgraph Server_Cluster [App Nodes - GPU Enabled]
        S1[Server 1: GPU Node]
        S2[Server 2: GPU Node]
        S3[Server 3: GPU Node]
    end

    %% Define Watchdog internal to a server
    subgraph Inside_Server [Internal Node Processes]
        App[PyTorch API Process]
        Nvidia[(NVIDIA GPU)]
        Watchdog{Bash Watchdog<br/>scripts/monitor_watchdog.sh}
    end

    %% Routing
    Client --> DNS
    DNS --> LB
    LB -- Round Robin --> S1
    LB -- Round Robin --> S2
    LB -- Round Robin --> S3

    %% Internal Node logic
    S1 -.-> Inside_Server
    App -->|Executes Tensors| Nvidia
    Watchdog -->|Polls Usage 30s| Nvidia
    Watchdog -- Kills if >90% --> App

    %% Health checks
    LB -. Health Check ping .-> App
```

## How It Works (The 3-Server Model)

1. **Inbound Traffic:** A user sends an inference request. The Load Balancer receives it and checks which of the three GPU servers (S1, S2, or S3) is currently healthy and has the least active connections.
2. **GPU Execution:** The request is routed to `Server 1`. The PyTorch API process loads the model into the NVIDIA GPU (profiled by our `memory_profile.py` logic).
3. **The Watchdog Failsafe:** While the model runs, `monitor_watchdog.sh` runs silently in the background. If the request causes a massive memory spike, the watchdog detects usage >90%.
4. **Self-Healing:** The watchdog kills the runaway PyTorch process. The Load Balancer detects that `Server 1`'s API is temporarily down and routes new traffic to `Server 2` and `Server 3` while `Server 1` reboots.