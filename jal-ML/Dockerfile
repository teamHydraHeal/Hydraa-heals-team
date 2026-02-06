# ─── Stage: Python ML Backend ───
FROM python:3.11-slim

WORKDIR /app

# Install dependencies first (cached layer)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# Copy project files
COPY backend.py .
COPY index.html .
COPY ML/ ML/

# Train model (ensures model.joblib is built inside the container)
RUN python ML/train_model.py

# Expose the backend port
EXPOSE 5001

# Run with gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:5001", "--workers", "2", "--timeout", "120", "backend:app"]
