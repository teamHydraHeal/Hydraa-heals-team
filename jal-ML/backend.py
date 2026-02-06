from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import pandas as pd
import joblib
import os
import sys

# Add ML directory to path to import engines
sys.path.append(os.path.join(os.path.dirname(__file__), "ML"))

from risk_engine import compute_total_risk, risk_to_status
from advisory_engine import generate_advisory
from text_extractor import extract_from_text

app = Flask(__name__, static_folder=".")
CORS(app)

# Load model if it exists
MODEL_PATH = os.path.join("ML", "trained_model", "model.joblib")
LE_PATH = os.path.join("ML", "trained_model", "label_encoder.joblib")
FEATURES_PATH = os.path.join("ML", "trained_model", "features.joblib")

model = None
le = None
features = None

@app.route("/", methods=["GET"])
def home():
    return send_from_directory(".", "index.html")

if os.path.exists(MODEL_PATH):
    try:
        model = joblib.load(MODEL_PATH)
        le = joblib.load(LE_PATH)
        features = joblib.load(FEATURES_PATH)
        print("ML Model loaded successfully.")
    except Exception as e:
        print(f"Error loading model: {e}")

@app.route("/predict", methods=["POST"])
def predict():
    data = request.json
    print(f"Received Request Data: {data}")
    
    # Check if we have a text report
    report_text = data.get("report_text")
    if report_text:
        health_data = extract_from_text(report_text)
        data.update(health_data)
    
    # Prepare row for risk engine and ML model
    # Features: ph, turbidity, orp, rainfall, diarrhea, vomiting, fever
    row = {
        "ph": float(data.get("ph", 7.0)),
        "turbidity": float(data.get("turbidity", 1.0)),
        "orp": float(data.get("orp", 300.0)),
        "rainfall": float(data.get("rainfall", 0.0)),
        "diarrhea": int(data.get("diarrhea", 0)),
        "vomiting": int(data.get("vomiting", 0)),
        "fever": int(data.get("fever", 0))
    }
    
    # 1. Use Rule-based Risk Engine
    total_risk, risks = compute_total_risk(pd.Series(row))
    rule_status = risk_to_status(total_risk, risks["available_signals"])
    
    # 2. Use ML Model (if available)
    ml_status = None
    if model and le:
        try:
            X = pd.DataFrame([row])[features]
            pred_enc = model.predict(X)
            ml_status = le.inverse_transform(pred_enc)[0]
        except Exception as e:
            print(f"ML prediction error: {e}")
            ml_status = "ERROR"
            
    # 3. Generate Advisory
    current_status = ml_status if ml_status and ml_status != "ERROR" else rule_status
    advisory_row = {
        "status": current_status,
        "r_turb": risks["turbidity"],
        "r_rain": risks["rainfall"],
        "r_health": risks["health"]
    }
    advisory = generate_advisory(advisory_row)
    
    return jsonify({
        "status": current_status,
        "rule_status": rule_status,
        "ml_status": ml_status,
        "total_risk": total_risk,
        "risks": risks,
        "advisory": advisory,
        "processed_data": row
    })

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5001))
    app.run(host="0.0.0.0", port=port)
