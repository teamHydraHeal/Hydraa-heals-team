# ─── Stage: Python ML Backend ───
FROM python:3.11-slim

WORKDIR /app

# Install curl for healthchecks
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

# Install dependencies first (cached layer)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# Copy project files
COPY backend.py .
COPY index.html .
COPY ML/ ML/

# Train model (ensures model.joblib is built inside the container)
RUN python ML/train_model.py

# Ollama runs as a separate container — point to it
ENV OLLAMA_URL=http://ollama:11434
ENV OLLAMA_MODEL=gemma2:2b

# Expose the backend port
EXPOSE 5001

# Run with gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:5001", "--workers", "2", "--timeout", "120", "backend:app"]
