/*
 * JalGuard — ESP32 Water Quality Monitor
 * ========================================
 * Sensors : TDS (Analog), DS18B20 Temperature (OneWire)
 * Outputs : RGB LED, DFPlayer Mini + PAM8403 Amp + Speaker
 * Input   : Push Button (acknowledge alert)
 *
 * Pin Connections:
 *   TDS Sensor   → GPIO32 (ADC)
 *   DS18B20      → GPIO4  (OneWire, 4.7kΩ pull-up to 3.3V)
 *   RGB LED (R)  → GPIO12
 *   RGB LED (G)  → GPIO27
 *   RGB LED (B)  → GPIO26
 *   DFPlayer TX  → GPIO16 (RX2)
 *   DFPlayer RX  → GPIO17 (TX2)
 *   Push Button  → GPIO23 (INPUT_PULLUP)
 *
 * Audio Files on SD Card:
 *   0001.mp3 — Green zone (water is safe)
 *   0002.mp3 — Yellow zone (caution)
 *   0003.mp3 — Red zone (danger)
 */

#include <OneWire.h>
#include <DallasTemperature.h>
#include <DFRobotDFPlayerMini.h>
#include <WiFi.h>
#include <HTTPClient.h>

// ─── Pin Definitions ───────────────────────────────
#define TDS_PIN       32
#define TEMP_PIN      4
#define LED_R         12
#define LED_G         27
#define LED_B         26
#define BUTTON_PIN    23

// ─── WiFi & Backend Config ─────────────────────────
const char* WIFI_SSID     = "Mahawar_5g";
const char* WIFI_PASSWORD = "manu0205";
const char* BACKEND_URL   = "http://35.226.149.77:9090/api/iot/data";
const char* SENSOR_ID     = "JG001";
const char* LOCATION_ID   = "field_station_01";

// ─── Sensor Objects ────────────────────────────────
OneWire oneWire(TEMP_PIN);
DallasTemperature tempSensor(&oneWire);
HardwareSerial mySerial(2);           // UART2 for DFPlayer
DFRobotDFPlayerMini dfPlayer;

// ─── Thresholds ────────────────────────────────────
const int TDS_GREEN    = 300;
const int TDS_YELLOW   = 500;
const int TDS_CRITICAL = 2000;

const float TEMP_GREEN    = 34.0;
const float TEMP_YELLOW   = 36.0;
const float TEMP_CRIT1    = 45.0;
const float TEMP_CRIT2    = 50.0;

// ─── State ─────────────────────────────────────────
float   tdsValue       = 0;
float   temperature    = 0;
int     currentZone    = 0;   // 0=green, 1=yellow, 2=red
bool    alertActive    = false;
bool    acked          = false;
unsigned long lastRead = 0;
unsigned long lastSend = 0;
const unsigned long READ_INTERVAL = 2000;   // 2 s
const unsigned long SEND_INTERVAL = 30000;  // 30 s

// ─── Forward Declarations ──────────────────────────
float  readTDS();
float  readTemperature();
int    evaluateZone(float tds, float temp);
void   setLED(int zone);
void   playAlert(int zone);
void   sendToBackend(float tds, float temp);
void   checkButton();

// ────────────────────────────────────────────────────
void setup() {
    Serial.begin(115200);
    Serial.println("[JalGuard] Booting...");

    // Pins
    pinMode(LED_R, OUTPUT);
    pinMode(LED_G, OUTPUT);
    pinMode(LED_B, OUTPUT);
    pinMode(BUTTON_PIN, INPUT_PULLUP);
    analogReadResolution(12);

    // Sensors
    tempSensor.begin();

    // DFPlayer
    mySerial.begin(9600, SERIAL_8N1, 16, 17);
    delay(500);
    if (dfPlayer.begin(mySerial)) {
        Serial.println("[DFPlayer] OK");
        dfPlayer.volume(25);
    } else {
        Serial.println("[DFPlayer] FAIL — check wiring");
    }

    // WiFi
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    Serial.print("[WiFi] Connecting");
    int tries = 0;
    while (WiFi.status() != WL_CONNECTED && tries < 40) {
        delay(500);
        Serial.print(".");
        tries++;
    }
    if (WiFi.status() == WL_CONNECTED) {
        Serial.printf("\n[WiFi] Connected — IP: %s\n", WiFi.localIP().toString().c_str());
    } else {
        Serial.println("\n[WiFi] FAILED — running offline");
    }

    // Initial LED
    setLED(0);
    Serial.println("[JalGuard] Ready");
}

// ────────────────────────────────────────────────────
void loop() {
    unsigned long now = millis();

    // Read sensors periodically
    if (now - lastRead >= READ_INTERVAL) {
        lastRead = now;

        tdsValue    = readTDS();
        temperature = readTemperature();
        int zone    = evaluateZone(tdsValue, temperature);

        Serial.printf("[Sensors] TDS=%.0f ppm  Temp=%.1f°C  Zone=%d\n",
                      tdsValue, temperature, zone);

        // Zone changed → new alert
        if (zone != currentZone) {
            currentZone = zone;
            setLED(zone);
            alertActive = (zone > 0);
            acked = false;
            if (alertActive) {
                playAlert(zone);
            }
        }

        // Auto-repeat red alert if not acked
        if (currentZone == 2 && alertActive && !acked) {
            static unsigned long lastRepeat = 0;
            if (now - lastRepeat > 15000) {
                playAlert(2);
                lastRepeat = now;
            }
        }
    }

    // Send data to backend periodically
    if (now - lastSend >= SEND_INTERVAL) {
        lastSend = now;
        sendToBackend(tdsValue, temperature);
    }

    checkButton();
}

// ─── TDS Reading (30-sample average) ───────────────
float readTDS() {
    const int SAMPLES = 30;
    long sum = 0;
    for (int i = 0; i < SAMPLES; i++) {
        sum += analogRead(TDS_PIN);
        delay(10);
    }
    float avgVoltage = (sum / (float)SAMPLES) * 3.3 / 4095.0;

    // Polynomial conversion (calibrated)
    float tds = (133.42 * avgVoltage * avgVoltage * avgVoltage
               - 255.86 * avgVoltage * avgVoltage
               + 857.39 * avgVoltage) * 0.5;
    return max(0.0f, tds);
}

// ─── Temperature Reading ───────────────────────────
float readTemperature() {
    tempSensor.requestTemperatures();
    float t = tempSensor.getTempCByIndex(0);
    if (t == DEVICE_DISCONNECTED_C) {
        Serial.println("[Temp] Sensor disconnected!");
        return -999;
    }
    return t;
}

// ─── Zone Evaluation ───────────────────────────────
int evaluateZone(float tds, float temp) {
    // Red if any critical threshold
    if (tds > TDS_CRITICAL || temp > TEMP_CRIT2) return 2;
    if (tds > TDS_YELLOW   || temp > TEMP_YELLOW) return 1;
    return 0;
}

// ─── RGB LED Control ───────────────────────────────
void setLED(int zone) {
    switch (zone) {
        case 0:  // Green
            digitalWrite(LED_R, LOW);
            digitalWrite(LED_G, HIGH);
            digitalWrite(LED_B, LOW);
            break;
        case 1:  // Yellow (R+G)
            digitalWrite(LED_R, HIGH);
            digitalWrite(LED_G, HIGH);
            digitalWrite(LED_B, LOW);
            break;
        case 2:  // Red
            digitalWrite(LED_R, HIGH);
            digitalWrite(LED_G, LOW);
            digitalWrite(LED_B, LOW);
            break;
    }
}

// ─── Audio Alert via DFPlayer ──────────────────────
void playAlert(int zone) {
    int track = zone + 1;  // 1=green, 2=yellow, 3=red
    Serial.printf("[Audio] Playing track %d\n", track);
    dfPlayer.play(track);
}

// ─── Button Handler (acknowledge alert) ────────────
void checkButton() {
    static bool lastState = HIGH;
    bool state = digitalRead(BUTTON_PIN);

    if (lastState == HIGH && state == LOW) {
        // Button pressed (falling edge, debounce via INPUT_PULLUP)
        delay(50);  // debounce
        if (digitalRead(BUTTON_PIN) == LOW) {
            Serial.println("[Button] Alert acknowledged");
            acked = true;
            alertActive = false;
        }
    }
    lastState = state;
}

// ─── Send Data to Backend ──────────────────────────
void sendToBackend(float tds, float temp) {
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("[HTTP] No WiFi — skipping");
        return;
    }

    HTTPClient http;
    http.begin(BACKEND_URL);
    http.addHeader("Content-Type", "application/json");

    // Build JSON payload
    String json = "{";
    json += "\"sensor_id\":\"" + String(SENSOR_ID) + "\",";
    json += "\"location_id\":\"" + String(LOCATION_ID) + "\",";
    json += "\"tds\":" + String(tds, 1) + ",";
    json += "\"temperature\":" + String(temp, 1) + ",";
    json += "\"turbidity\":" + String(tds * 0.01, 2) + ",";  // Estimate turbidity from TDS
    json += "\"timestamp\":\"" + String(millis()) + "\"";
    json += "}";

    Serial.printf("[HTTP] POST %s\n", BACKEND_URL);
    int httpCode = http.POST(json);

    if (httpCode > 0) {
        Serial.printf("[HTTP] Response %d: %s\n", httpCode, http.getString().c_str());
    } else {
        Serial.printf("[HTTP] Error: %s\n", http.errorToString(httpCode).c_str());
    }

    http.end();
}
