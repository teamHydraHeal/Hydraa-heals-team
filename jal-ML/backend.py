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
# Summarize & Translate Action Plan using Ollama LLM
# Generates clear, conversational health advisories
# that regional people can understand via TTS
# ────────────────────────────────────────────────────
import json as json_module
import requests as py_requests

OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://localhost:11434")
OLLAMA_MODEL = os.environ.get("OLLAMA_MODEL", "qwen2.5:1.5b")
OLLAMA_TIMEOUT_SEC = int(os.environ.get("OLLAMA_TIMEOUT_SEC", "45"))
OLLAMA_KEEP_ALIVE = os.environ.get("OLLAMA_KEEP_ALIVE", "30m")
OLLAMA_NUM_PREDICT = int(os.environ.get("OLLAMA_NUM_PREDICT", "120"))
OLLAMA_NUM_CTX = int(os.environ.get("OLLAMA_NUM_CTX", "1024"))
OLLAMA_TEMPERATURE = float(os.environ.get("OLLAMA_TEMPERATURE", "0.4"))
OLLAMA_TOP_P = float(os.environ.get("OLLAMA_TOP_P", "0.9"))
CHAT_MAX_HISTORY = int(os.environ.get("CHAT_MAX_HISTORY", "6"))
CHAT_HISTORY_CHAR_LIMIT = int(os.environ.get("CHAT_HISTORY_CHAR_LIMIT", "500"))


def _build_ollama_prompt(action_plan):
    """Build a prompt for the LLM to generate a citizen-friendly health advisory."""

    # Extract key data points
    ml_pred = action_plan.get("ml_prediction", {})
    situation = action_plan.get("situation_analysis", {})
    action_items = action_plan.get("action_items", [])
    timeline = action_plan.get("timeline", [])

    # Build data context
    data_lines = []

    if ml_pred:
        status = ml_pred.get("status", "unknown")
        risk = ml_pred.get("total_risk", 0)
        risk_pct = int(float(risk) * 100) if isinstance(risk, (int, float)) else 0
        advisory = ml_pred.get("advisory", "")
        risks = ml_pred.get("risks", {})
        data_lines.append(f"Water Safety Status: {status}")
        data_lines.append(f"Overall Risk: {risk_pct}%")
        if advisory:
            data_lines.append(f"ML Advisory: {advisory}")
        if risks:
            for k, v in risks.items():
                data_lines.append(f"  - {k}: {v}")

    if situation:
        for k, v in situation.items():
            if v:
                data_lines.append(f"{k}: {v}")

    if action_items:
        data_lines.append("Action Steps:")
        for i, item in enumerate(action_items[:6]):
            if isinstance(item, dict):
                title = item.get("title", item.get("action", ""))
                desc = item.get("description", "")
                if title:
                    data_lines.append(f"  {i+1}. {title}" + (f" - {desc}" if desc else ""))

    data_context = "\n".join(data_lines)

    prompt = f"""You are a public health advisor for Jal Guard, a water safety system in Meghalaya, India. 
Based on the sensor data and analysis below, create a SHORT, CLEAR health advisory for ordinary citizens.

WATER QUALITY DATA:
{data_context}

INSTRUCTIONS:
- Write as if speaking directly to a village resident
- Explain in simple words: Is the water safe? Why or why not?
- If pH is too high or low, explain what that means for health
- Give 3-4 specific precautions they should take
- Mention if they should boil water, use filters, or avoid the source
- Keep it under 150 words — this will be read aloud via text-to-speech
- Do NOT use technical jargon, bullet points, or markdown formatting
- Do NOT use emoji or emoticons
- Write in natural, conversational sentences as a caring health worker would speak

ADVISORY:"""

    return prompt


def _call_ollama(prompt):
    """Call Ollama API to generate text."""
    try:
        resp = py_requests.post(
            f"{OLLAMA_URL}/api/generate",
            json={
                "model": OLLAMA_MODEL,
                "prompt": prompt,
                "stream": False,
                "keep_alive": OLLAMA_KEEP_ALIVE,
                "options": {
                    "temperature": OLLAMA_TEMPERATURE,
                    "top_p": OLLAMA_TOP_P,
                    "num_ctx": OLLAMA_NUM_CTX,
                    "num_predict": OLLAMA_NUM_PREDICT,
                }
            },
            timeout=OLLAMA_TIMEOUT_SEC,
        )
        if resp.status_code == 200:
            data = resp.json()
            return data.get("response", "").strip()
        else:
            print(f"Ollama error {resp.status_code}: {resp.text}")
            return None
    except Exception as e:
        print(f"Ollama request failed: {e}")
        return None


def _fallback_summary(action_plan):
    """Rule-based fallback if Ollama is unavailable."""
    ml_pred = action_plan.get("ml_prediction", {})
    situation = action_plan.get("situation_analysis", {})
    action_items = action_plan.get("action_items", [])
    parts = []

    if ml_pred:
        status = ml_pred.get("status", "unknown")
        risk = ml_pred.get("total_risk", 0)
        risk_pct = int(float(risk) * 100) if isinstance(risk, (int, float)) else 0
        advisory = ml_pred.get("advisory", "")

        if status.lower() in ("unsafe", "danger", "critical"):
            parts.append(f"Warning! The water in your area is not safe to drink. The risk level is {risk_pct} percent.")
        elif status.lower() in ("caution", "moderate"):
            parts.append(f"Be careful. The water in your area may not be fully safe. Risk level is {risk_pct} percent.")
        else:
            parts.append(f"The water in your area appears safe for now. Risk level is {risk_pct} percent.")
        if advisory:
            parts.append(advisory)

    risk_level = situation.get("risk_level", "")
    if risk_level:
        parts.append(f"The current risk level is {risk_level}.")

    if action_items:
        parts.append("Here is what you should do.")
        for i, item in enumerate(action_items[:4]):
            if isinstance(item, dict):
                title = item.get("title", item.get("action", ""))
                if title:
                    parts.append(f"Step {i+1}: {title}.")

    parts.append("Please boil all drinking water. If anyone feels sick, visit your nearest health center immediately.")
    return " ".join(parts)


@app.route("/summarize", methods=["POST"])
def summarize_action_plan():
    """Generate a clear, conversational health advisory using Ollama LLM,
    then translate it for regional TTS playback.

    Request JSON:
        action_plan (dict): The full action plan data
        target_language (str): Language for translation (e.g., "hindi")

    Returns: JSON with English + translated summary
    """
    data = request.json or {}
    action_plan = data.get("action_plan", {})
    target_lang = data.get("target_language", "hindi").lower()

    # --- Generate summary using Ollama LLM ---
    prompt = _build_ollama_prompt(action_plan)
    english_summary = _call_ollama(prompt)

    llm_used = True
    if not english_summary:
        # Fallback to rule-based if Ollama is down
        english_summary = _fallback_summary(action_plan)
        llm_used = False

    # --- Translate to target language ---
    target_code = TRANSLATE_CODES.get(target_lang, "hi")

    if target_lang == "english" or target_code == "en":
        return jsonify({
            "summary_english": english_summary,
            "summary_translated": english_summary,
            "target_language": target_lang,
            "llm_used": llm_used,
        })

    try:
        # Translate sentence by sentence for better quality
        sentences = [s.strip() for s in english_summary.replace("\n", " ").split(". ") if s.strip()]
        translated_parts = []
        for sentence in sentences:
            try:
                translator = GoogleTranslator(source="en", target=target_code)
                translated = translator.translate(sentence + ".")
                translated_parts.append(translated if translated else sentence + ".")
            except:
                translated_parts.append(sentence + ".")

        translated_summary = " ".join(translated_parts)

        return jsonify({
            "summary_english": english_summary,
            "summary_translated": translated_summary,
            "target_language": target_lang,
            "llm_used": llm_used,
        })
    except Exception as e:
        traceback.print_exc()
        return jsonify({
            "summary_english": english_summary,
            "summary_translated": english_summary,
            "target_language": target_lang,
            "llm_used": llm_used,
            "error": f"Translation failed: {str(e)}"
        })


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
import re
import unicodedata

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


def _clean_text_for_tts(text):
    """Normalize text and strip emoji/symbol characters so TTS sounds natural."""
    if not text:
        return ""

    # Normalize compatibility glyphs (full-width chars, etc.).
    normalized = unicodedata.normalize("NFKC", text)

    cleaned_chars = []
    for ch in normalized:
        cat = unicodedata.category(ch)
        # Drop most symbol categories (emoji, dingbats, pictographs, misc symbols).
        if cat in {"So", "Sk", "Cs"}:
            continue
        cleaned_chars.append(ch)

    cleaned = "".join(cleaned_chars)
    # Collapse repeated punctuation/noise and normalize whitespace.
    cleaned = re.sub(r"[_~`^|]+", " ", cleaned)
    cleaned = re.sub(r"\s+", " ", cleaned).strip()
    return cleaned


def _clean_chat_output_text(text):
    """Strip emojis, emoticons, and decorative symbols from chat responses."""
    if not text:
        return ""

    cleaned = _clean_text_for_tts(text)

    # Remove common text emoticons that TTS may read literally.
    emoticon_patterns = [
        r"(:-?\)|:-?\(|;-?\)|:-?D|:-?P|:-?p|:'\(|:\*|<3)",
        r"(\^_\^|\^\.\^|\^\-\^|T_T|xD|XD)",
    ]
    for pat in emoticon_patterns:
        cleaned = re.sub(pat, " ", cleaned)

    # Keep only letters/numbers/whitespace and minimal sentence punctuation.
    cleaned = "".join(
        ch for ch in cleaned
        if ch.isalnum() or ch.isspace() or ch in {".", ",", "?", "!", "-", "'"}
    )

    cleaned = re.sub(r"\s+", " ", cleaned).strip()
    return cleaned


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

    # Remove emojis/symbol noise so audio is clean and understandable.
    text = _clean_text_for_tts(text)
    if not text:
        return jsonify({"error": "Text contains no speakable content after cleanup"}), 400

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


# ────────────────────────────────────────────────────
# Ollama Chat Endpoint — powers the AI Co-pilot chat
# ────────────────────────────────────────────────────
CHAT_SYSTEM_PROMPT = """You are Jal Guard AI, a friendly public-health assistant for water safety in Meghalaya, India.

Guidelines:
- Reply in simple, practical language for citizens and officials.
- Keep default answers short (2-4 sentences), unless asked for detail.
- Explain pH, turbidity, ORP, and contamination in health terms.
- For unsafe water, give clear precautions (boil, filter, avoid source).
- Help interpret ML predictions, risk scores, and action plans.
- Be respectful of local culture and Khasi-speaking communities.
- Never use emojis or emoticons in responses.

Reference thresholds:
- Safe pH: 6.5 to 8.5.
- Turbidity > 5 NTU can indicate contamination risk.
- ORP < 200 mV can indicate weak disinfection."""


@app.route("/chat", methods=["POST"])
def chat():
    """Ollama-powered chat for the AI Co-pilot.

    Request JSON:
        message (str): The user's message
        history (list): Optional conversation history [{role, content}, ...]
        context (dict): Optional context (current action plan, ML data, etc.)

    Returns: JSON with the AI's response
    """
    data = request.json or {}
    user_message = data.get("message", "").strip()
    history = data.get("history", [])
    context = data.get("context", {})

    if not user_message:
        return jsonify({"error": "No message provided"}), 400

    # Build messages for Ollama
    prompt_parts = [CHAT_SYSTEM_PROMPT]

    # Inject context if provided (action plan, ML data, etc.)
    if context:
        ctx_str = json_module.dumps(context, indent=2, default=str)
        prompt_parts.append(f"\n--- Current Context ---\n{ctx_str}\n--- End Context ---\n")

    # Add conversation history
    for msg in history[-CHAT_MAX_HISTORY:]:
        role = msg.get("role", "user")
        content = msg.get("content", "")[:CHAT_HISTORY_CHAR_LIMIT]
        if role == "user":
            prompt_parts.append(f"\nUser: {content}")
        else:
            prompt_parts.append(f"\nAssistant: {content}")

    # Add current user message
    prompt_parts.append(f"\nUser: {user_message}")
    prompt_parts.append("\nAssistant:")

    full_prompt = "\n".join(prompt_parts)

    # Call Ollama
    response_text = _call_ollama(full_prompt)

    if response_text:
        # Enforce symbol-free responses so readout stays clean.
        response_text = _clean_chat_output_text(response_text)
        return jsonify({
            "response": response_text,
            "llm_used": True,
            "model": OLLAMA_MODEL,
        })
    else:
        # Fallback to simple rule-based response
        fallback = _fallback_chat(user_message)
        fallback = _clean_chat_output_text(fallback)
        return jsonify({
            "response": fallback,
            "llm_used": False,
            "model": "fallback",
        })


def _fallback_chat(message):
    """Simple keyword-based fallback when Ollama is unavailable."""
    msg = message.lower()
    if any(w in msg for w in ["risk", "situation", "status"]):
        return "Based on current data, there are active water quality concerns. I recommend generating an action plan for a detailed analysis. Note: The AI model is currently offline and responses are limited."
    elif any(w in msg for w in ["safe", "drink", "water"]):
        return "For safety, always boil water before drinking if there are any quality concerns. Check the latest ML prediction for your area's water safety status."
    elif any(w in msg for w in ["help", "what can"]):
        return ("I can help with water quality analysis, health risk assessment, action plan generation, and precaution recommendations. "
            "Note: The AI model is offline. Start Ollama for full AI capabilities.")
    elif any(w in msg for w in ["hi", "hello", "hey"]):
        return "Hello! I'm Jal Guard AI. I can help you understand water quality data and health risks. What would you like to know?"
    else:
        return "I'm here to help with water quality and health concerns. The AI model is currently offline, so my responses are limited. Try asking about water safety, risk levels, or action plans."


# ────────────────────────────────────────────────────
# Ollama Status Check
# ────────────────────────────────────────────────────
# ────────────────────────────────────────────────────
# IoT Sensor Data Ingestion — ESP32 sensor pods
# Accepts TDS, temperature, turbidity from field devices
# ────────────────────────────────────────────────────
import threading
import time as _time

# In-memory store for latest readings per sensor (production: use DB)
_iot_readings = {}          # sensor_id -> latest reading dict
_iot_readings_lock = threading.Lock()

# WHO / BIS safety thresholds
IOT_THRESHOLDS = {
    "tds":         {"safe_max": 500, "caution_max": 1000, "unit": "ppm"},
    "temperature": {"safe_max": 35,  "caution_max": 45,   "unit": "°C"},
    "turbidity":   {"safe_max": 5,   "caution_max": 10,   "unit": "NTU"},
}


def _evaluate_water_quality(tds, temperature, turbidity):
    """Return quality_score (0-1, lower=safer), status, and per-parameter flags."""
    issues = []
    score = 0.0

    # TDS
    if tds > IOT_THRESHOLDS["tds"]["caution_max"]:
        score += 0.4
        issues.append(f"TDS critically high ({tds} ppm)")
    elif tds > IOT_THRESHOLDS["tds"]["safe_max"]:
        score += 0.2
        issues.append(f"TDS elevated ({tds} ppm)")

    # Temperature
    if temperature > IOT_THRESHOLDS["temperature"]["caution_max"]:
        score += 0.3
        issues.append(f"Temperature very high ({temperature}°C)")
    elif temperature > IOT_THRESHOLDS["temperature"]["safe_max"]:
        score += 0.15
        issues.append(f"Temperature elevated ({temperature}°C)")

    # Turbidity
    if turbidity > IOT_THRESHOLDS["turbidity"]["caution_max"]:
        score += 0.4
        issues.append(f"Turbidity critically high ({turbidity} NTU)")
    elif turbidity > IOT_THRESHOLDS["turbidity"]["safe_max"]:
        score += 0.2
        issues.append(f"Turbidity elevated ({turbidity} NTU)")

    score = min(score, 1.0)

    if score >= 0.6:
        status = "UNSAFE"
    elif score >= 0.3:
        status = "CAUTION"
    else:
        status = "SAFE"

    return score, status, issues


@app.route("/api/iot/data", methods=["POST"])
def iot_ingest():
    """Ingest sensor readings from ESP32 pods.

    Request JSON:
        sensor_id (str): Unique device identifier (e.g. "JG001")
        location_id (str): Deployment location label
        timestamp (str): ISO-8601 timestamp from device
        tds (float): Total Dissolved Solids in ppm
        temperature (float): Water temperature in °C
        turbidity (float): Water clarity in NTU
        battery (float, optional): Battery percentage

    Returns: JSON with quality evaluation and risk assessment
    """
    data = request.json or {}

    sensor_id = data.get("sensor_id", "").strip()
    if not sensor_id:
        return jsonify({"error": "sensor_id is required"}), 400

    tds = float(data.get("tds", 0))
    temperature = float(data.get("temperature", 0))
    turbidity = float(data.get("turbidity", 0))
    location_id = data.get("location_id", "unknown")
    timestamp = data.get("timestamp", "")
    battery = data.get("battery")

    # Evaluate water quality
    quality_score, quality_status, issues = _evaluate_water_quality(tds, temperature, turbidity)

    # Build risk-engine compatible row and run prediction
    risk_row = pd.Series({
        "ph": 7.0,  # Default — ESP32 pod doesn't have pH sensor
        "turbidity": turbidity,
        "orp": 300.0,  # Default — no ORP sensor
        "rainfall": 0.0,
        "diarrhea": 0,
        "vomiting": 0,
        "fever": 0,
    })
    total_risk, risks = compute_total_risk(risk_row)

    # Add TDS-based risk contribution (not in original engine)
    tds_risk = 0.0
    if tds > 2000:
        tds_risk = 1.0
    elif tds > 1000:
        tds_risk = 0.6
    elif tds > 500:
        tds_risk = 0.3
    elif tds > 300:
        tds_risk = 0.1

    # Temperature risk for bacterial growth
    temp_risk = 0.0
    if temperature > 45:
        temp_risk = 0.8
    elif temperature > 35:
        temp_risk = 0.4
    elif temperature > 30:
        temp_risk = 0.2

    # Combined IoT risk = original engine + TDS/temp contributions
    combined_risk = min(1.0, total_risk + 0.2 * tds_risk + 0.15 * temp_risk)
    combined_status = risk_to_status(combined_risk, max(risks["available_signals"], 2))

    # Store latest reading
    reading = {
        "sensor_id": sensor_id,
        "location_id": location_id,
        "timestamp": timestamp,
        "tds": tds,
        "temperature": temperature,
        "turbidity": turbidity,
        "battery": battery,
        "quality_score": quality_score,
        "quality_status": quality_status,
        "combined_risk": combined_risk,
        "combined_status": combined_status,
        "received_at": _time.strftime("%Y-%m-%dT%H:%M:%SZ", _time.gmtime()),
    }

    with _iot_readings_lock:
        _iot_readings[sensor_id] = reading

    print(f"[IoT] {sensor_id}: TDS={tds}, Temp={temperature}, Turb={turbidity} → {quality_status} (risk={combined_risk:.2f})")

    return jsonify({
        "status": "ok",
        "sensor_id": sensor_id,
        "quality": {
            "score": quality_score,
            "status": quality_status,
            "issues": issues,
        },
        "risk": {
            "total_risk": combined_risk,
            "status": combined_status,
            "tds_risk": tds_risk,
            "temp_risk": temp_risk,
            "turbidity_risk": risks["turbidity"],
            "engine_risks": risks,
        },
        "thresholds": IOT_THRESHOLDS,
    })


@app.route("/api/iot/latest", methods=["GET"])
def iot_latest():
    """Return latest readings from all registered sensor pods.

    Query params:
        sensor_id (str, optional): Filter by specific sensor
    """
    sensor_id = request.args.get("sensor_id", "").strip()

    with _iot_readings_lock:
        if sensor_id:
            reading = _iot_readings.get(sensor_id)
            if reading:
                return jsonify({"readings": [reading]})
            return jsonify({"readings": [], "message": f"No data for {sensor_id}"}), 404
        return jsonify({"readings": list(_iot_readings.values())})


@app.route("/api/iot/status", methods=["GET"])
def iot_device_status():
    """Return summary of all known sensor pods — useful for dashboard."""
    with _iot_readings_lock:
        devices = []
        for sid, r in _iot_readings.items():
            devices.append({
                "sensor_id": sid,
                "location_id": r.get("location_id"),
                "quality_status": r.get("quality_status"),
                "combined_risk": r.get("combined_risk"),
                "battery": r.get("battery"),
                "last_seen": r.get("received_at"),
            })
    return jsonify({"devices": devices, "count": len(devices)})


# ────────────────────────────────────────────────────
# Ollama Status Check
# ────────────────────────────────────────────────────
@app.route("/ollama/status", methods=["GET"])
def ollama_status():
    """Check if Ollama is running and the configured model is available."""
    try:
        resp = py_requests.get(f"{OLLAMA_URL}/api/tags", timeout=5)
        if resp.status_code == 200:
            models = [m["name"] for m in resp.json().get("models", [])]
            model_ready = any(OLLAMA_MODEL in m for m in models)
            return jsonify({
                "ollama_running": True,
                "model": OLLAMA_MODEL,
                "model_ready": model_ready,
                "available_models": models,
            })
        return jsonify({"ollama_running": False, "error": f"HTTP {resp.status_code}"})
    except Exception as e:
        return jsonify({"ollama_running": False, "error": str(e)})


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5001))
    app.run(host="0.0.0.0", port=port)
