from flask import Flask, request, jsonify, send_from_directory, send_file
from flask_cors import CORS
import pandas as pd
import joblib
import os
import sys
import tempfile
import traceback

# Add ML directory to path to import engines
sys.path.append(os.path.join(os.path.dirname(__file__), "ML"))

from risk_engine import compute_total_risk, risk_to_status
from advisory_engine import generate_advisory
from text_extractor import extract_from_text

app = Flask(__name__, static_folder=".")
CORS(app)

# ────────────────────────────────────────────────────
# Translation (using deep-translator)
# ────────────────────────────────────────────────────
from deep_translator import GoogleTranslator

# Map language names to ISO codes for translation
TRANSLATE_CODES = {
    "english": "en",
    "hindi": "hi",
    "bengali": "bn",
    "gujarati": "gu",
    "marathi": "mr",
    "tamil": "ta",
    "telugu": "te",
    "kannada": "kn",
    "malayalam": "ml",
    "punjabi": "pa",
    "urdu": "ur",
    "nepali": "ne",
    "odia": "or",
}


@app.route("/translate", methods=["POST"])
def translate_text():
    """Translate text to target language using Google Translate.

    Request JSON:
        text (str): Text to translate
        target_language (str): Target language name (e.g., "hindi", "bengali")
        source_language (str, optional): Source language (default: "english")

    Returns: JSON with translated text
    """
    data = request.json or {}
    text = data.get("text", "").strip()
    target_lang = data.get("target_language", "hindi").lower()
    source_lang = data.get("source_language", "english").lower()

    if not text:
        return jsonify({"error": "No text provided"}), 400

    target_code = TRANSLATE_CODES.get(target_lang, "hi")
    source_code = TRANSLATE_CODES.get(source_lang, "en")

    # If same language, return as-is
    if target_code == source_code:
        return jsonify({"translated_text": text, "source": source_lang, "target": target_lang})

    try:
        translator = GoogleTranslator(source=source_code, target=target_code)
        translated = translator.translate(text)
        return jsonify({
            "translated_text": translated,
            "source": source_lang,
            "target": target_lang
        })
    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": f"Translation failed: {str(e)}"}), 500

# ────────────────────────────────────────────────────
# ML Model Loading
# ────────────────────────────────────────────────────
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

# ────────────────────────────────────────────────────
# Multilingual Text-to-Speech (gTTS - Google TTS)
# Supports Hindi, Bengali, Gujarati, Marathi,
# Tamil, Telugu, Kannada, Malayalam, Punjabi, etc.
# ────────────────────────────────────────────────────
from gtts import gTTS
import io

# Map language names → gTTS language codes
LANGUAGE_CODES = {
    "english":   "en",
    "hindi":     "hi",
    "bengali":   "bn",
    "gujarati":  "gu",
    "marathi":   "mr",
    "tamil":     "ta",
    "telugu":    "te",
    "kannada":   "kn",
    "malayalam": "ml",
    "punjabi":   "pa",
    "urdu":      "ur",
    "nepali":    "ne",
    "odia":      "or",   # Odia (limited)
}

# Display names for the Flutter UI
LANGUAGE_DISPLAY = {
    "english":   "English",
    "hindi":     "हिन्दी (Hindi)",
    "bengali":   "বাংলা (Bengali)",
    "gujarati":  "ગુજરાતી (Gujarati)",
    "marathi":   "मराठी (Marathi)",
    "tamil":     "தமிழ் (Tamil)",
    "telugu":    "తెలుగు (Telugu)",
    "kannada":   "ಕನ್ನಡ (Kannada)",
    "malayalam": "മലയാളം (Malayalam)",
    "punjabi":   "ਪੰਜਾਬੀ (Punjabi)",
    "urdu":      "اردو (Urdu)",
    "nepali":    "नेपाली (Nepali)",
    "odia":      "ଓଡ଼ିଆ (Odia)",
}


@app.route("/tts", methods=["POST"])
def text_to_speech():
    """Convert text to speech using gTTS (Google Text-to-Speech).

    Supports 14 Indian languages + English.

    Request JSON:
        text (str): Text to synthesize (any script — Devanagari, Bengali, etc.)
        language (str, optional): Language name (default: "hindi")

    Returns: audio/mp3 file
    """
    data = request.json or {}
    text = data.get("text", "").strip()
    language = data.get("language", "hindi").lower()

    if not text:
        return jsonify({"error": "No text provided"}), 400

    lang_code = LANGUAGE_CODES.get(language, "hi")

    try:
        tts = gTTS(text=text, lang=lang_code, slow=False)

        # Write to in-memory buffer (no temp file needed)
        audio_buffer = io.BytesIO()
        tts.write_to_fp(audio_buffer)
        audio_buffer.seek(0)

        return send_file(
            audio_buffer,
            mimetype="audio/mpeg",
            download_name="tts_output.mp3",
        )

    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": f"TTS generation failed: {str(e)}"}), 500


@app.route("/tts/languages", methods=["GET"])
def tts_languages():
    """Return list of supported TTS languages."""
    langs = [
        {"code": k, "gtts_code": v, "display": LANGUAGE_DISPLAY.get(k, k)}
        for k, v in LANGUAGE_CODES.items()
    ]
    return jsonify({"languages": langs})


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5001))
    app.run(host="0.0.0.0", port=port)
