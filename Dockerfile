# Use the official PyTorch image with CUDA support as the base
FROM pytorch/pytorch:latest

# Copy the scripts folder into the container so they're available at runtime
COPY scripts/ /app/scripts/

# Copy the source code folder (health API, memory profiler, etc.)
COPY src/ /app/src/

# Install additional Python packages needed by the health API
RUN pip install fastapi uvicorn

# Set the working directory so all relative paths resolve correctly
WORKDIR /app

# Default command: start the Health API server on port 8000
CMD ["uvicorn", "src.health_api:app", "--host", "0.0.0.0", "--port", "8000"]
