# Jalguard - Water Quality Intelligence

AI-powered water quality monitoring and risk assessment system.

## Features
- ML-based risk classification (Random Forest)
- Heuristic risk engine fallback
- NLP text extraction for health reports
- Interactive dashboard

## Local Development
1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
2. Train model:
   ```bash
   python ML/train_model.py
   ```
3. Run backend:
   ```bash
   python backend.py
   ```

## Deployment on Render
1. Create a new **Web Service**.
2. Connect this GitHub repository.
3. Select **Python** as the Runtime.
4. Build Command: `pip install -r requirements.txt && python ML/train_model.py`
5. Start Command: `gunicorn backend:app`
