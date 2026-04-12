# JalGuard — IoT Hardware Module

## Overview
ESP32-based water quality monitoring pod that reads TDS and temperature sensors, provides local RGB LED + audio alerts, and streams data to the JalGuard cloud backend.

## Components
| Component | Model | Purpose |
|-----------|-------|---------|
| Microcontroller | ESP32 DevKit V1 | WiFi + ADC + GPIO |
| TDS Sensor | Analog TDS Meter | Dissolved solids (ppm) |
| Temperature Sensor | DS18B20 (waterproof) | Water temperature (°C) |
| RGB LED | Common Cathode | Visual zone indicator |
| Audio Player | DFPlayer Mini | MP3 alert playback |
| Amplifier | PAM8403 | Speaker amplification |
| Speaker | 3W 4Ω | Audio output |
| Button | Momentary push | Alert acknowledgment |

## Wiring Diagram

```
ESP32 Pin   →  Component
──────────────────────────
GPIO32      →  TDS Sensor (Analog Out)
GPIO4       →  DS18B20 (Data) + 4.7kΩ pull-up to 3.3V
GPIO12      →  RGB LED Red
GPIO27      →  RGB LED Green
GPIO26      →  RGB LED Blue
GPIO16 (RX2)→  DFPlayer TX
GPIO17 (TX2)→  DFPlayer RX (via 1kΩ resistor)
GPIO23      →  Push Button (other leg to GND)
3.3V        →  TDS VCC, DS18B20 VCC
5V          →  DFPlayer VCC, PAM8403 VCC
GND         →  Common ground for all
```

## Setup

### 1. Arduino IDE
1. Install ESP32 board package (Espressif v2.x)
2. Install libraries: `OneWire`, `DallasTemperature`, `DFRobotDFPlayerMini`
3. Open `esp32_firmware/water_monitor.ino`
4. Update WiFi credentials and backend URL constants
5. Upload to ESP32

### 2. SD Card (DFPlayer)
Place MP3 files in root of FAT32-formatted microSD:
- `0001.mp3` — "Water quality is safe" (green zone)
- `0002.mp3` — "Caution: water quality degraded" (yellow zone)
- `0003.mp3` — "Danger: water unsafe for use" (red zone)

### 3. Backend Configuration
The ESP32 sends POST requests to:
```
http://<server-ip>:9090/api/iot/data
```

JSON payload:
```json
{
  "sensor_id": "JG001",
  "location_id": "field_station_01",
  "tds": 245.3,
  "temperature": 28.5,
  "turbidity": 2.45,
  "timestamp": "1234567890"
}
```

## Alert Zones
| Zone | TDS (ppm) | Temp (°C) | LED Color | Audio |
|------|-----------|-----------|-----------|-------|
| Green | < 300 | < 34 | 🟢 Green | Track 1 |
| Yellow | 300–500 | 34–36 | 🟡 Yellow | Track 2 |
| Red | > 500 | > 36 | 🔴 Red | Track 3 (auto-repeat) |

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/iot/data` | Ingest sensor readings |
| GET | `/api/iot/latest` | Latest readings from all/specific sensors |
| GET | `/api/iot/status` | Device summary for dashboard |
