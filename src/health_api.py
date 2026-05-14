from fastapi import FastAPI
import torch

app = FastAPI()


@app.get("/health")
def health():
    gpu_available = torch.cuda.is_available()
    return {"status": "healthy", "gpu": "detected" if gpu_available else "not found"}
