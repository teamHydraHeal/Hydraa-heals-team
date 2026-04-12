import pandas as pd


def ph_risk(ph):
    if pd.isna(ph):
        return 0.0

    if 6.5 <= ph <= 8.5:
        return 0.0

    if ph < 6.5:
        return min(1.0, (6.5 - ph) / 2.0)
    else:
        return min(1.0, (ph - 8.5) / 2.0)


def turbidity_risk(turbidity):
    if pd.isna(turbidity):
        return 0.0

    if turbidity < 5:
        return 0.1
    elif turbidity < 10:
        return 0.5
    else:
        return min(1.0, 0.7 + (turbidity - 10) / 20.0)


def orp_risk(orp):
    if pd.isna(orp):
        return 0.0

    if orp >= 300:
        return 0.1
    elif orp >= 250:
        return 0.4
    else:
        return min(1.0, 0.7 + (250 - orp) / 100.0)


def rainfall_risk(rainfall):
    if pd.isna(rainfall):
        return 0.0

    if rainfall < 5:
        return 0.1
    elif rainfall < 20:
        return 0.4
    else:
        return min(1.0, 0.7 + (rainfall - 20) / 60.0)


def health_risk(diarrhea, vomiting, fever):

    diarrhea = 0 if pd.isna(diarrhea) else diarrhea
    vomiting = 0 if pd.isna(vomiting) else vomiting
    fever = 0 if pd.isna(fever) else fever

    score = (
        1.0 * diarrhea +
        0.7 * vomiting +
        0.3 * fever
    )

    return min(1.0, score / 2.2)


def tds_risk(tds):
    """Total Dissolved Solids risk — WHO: <500 ppm safe, BIS: <300 desirable."""
    if pd.isna(tds):
        return 0.0

    if tds < 300:
        return 0.0
    elif tds < 500:
        return 0.2
    elif tds < 1000:
        return 0.5
    elif tds < 2000:
        return 0.8
    else:
        return 1.0


def temperature_risk(temp):
    """Water temperature risk — high temp promotes bacterial growth."""
    if pd.isna(temp):
        return 0.0

    if temp < 25:
        return 0.0
    elif temp < 30:
        return 0.1
    elif temp < 35:
        return 0.3
    elif temp < 45:
        return 0.6
    else:
        return 1.0


def compute_total_risk(row):

    r_ph = ph_risk(row["ph"])
    r_turb = turbidity_risk(row["turbidity"])
    r_orp = orp_risk(row["orp"])
    r_rain = rainfall_risk(row["rainfall"])
    r_health = health_risk(
        row["diarrhea"],
        row["vomiting"],
        row["fever"]
    )

    # IoT sensor fields (optional — present when ESP32 data is available)
    r_tds = tds_risk(row.get("tds") if hasattr(row, "get") else (row["tds"] if "tds" in row.index else None))
    r_temp = temperature_risk(row.get("water_temp") if hasattr(row, "get") else (row["water_temp"] if "water_temp" in row.index else None))

    available = 0

    if not pd.isna(row["ph"]):
        available += 1
    if not pd.isna(row["turbidity"]):
        available += 1
    if not pd.isna(row["orp"]):
        available += 1
    if not pd.isna(row["rainfall"]):
        available += 1

    # health report considered available if any symptom is present
    if not (
        pd.isna(row["diarrhea"]) and
        pd.isna(row["vomiting"]) and
        pd.isna(row["fever"])
    ):
        available += 1

    has_tds = r_tds > 0
    has_temp = r_temp > 0
    if has_tds:
        available += 1
    if has_temp:
        available += 1

    if has_tds or has_temp:
        # Re-weight to include IoT sensor contributions
        total = (
            0.10 * r_ph +
            0.20 * r_turb +
            0.10 * r_orp +
            0.10 * r_rain +
            0.25 * r_health +
            0.15 * r_tds +
            0.10 * r_temp
        )
    else:
        # Original weights when no IoT data
        total = (
            0.15 * r_ph +
            0.25 * r_turb +
            0.15 * r_orp +
            0.15 * r_rain +
            0.30 * r_health
        )

    return total, {
        "ph": r_ph,
        "turbidity": r_turb,
        "orp": r_orp,
        "rainfall": r_rain,
        "health": r_health,
        "tds": r_tds,
        "water_temp": r_temp,
        "available_signals": available
    }


def risk_to_status(total_risk, available_signals):

    if available_signals < 2:
        return "NO_DATA"

    if total_risk < 0.25:
        return "GREEN"
    elif total_risk < 0.55:
        return "YELLOW"
    else:
        return "RED"


if __name__ == "__main__":

    df = pd.read_csv("data/synthetic_with_text_features.csv")

    for i, row in df.iterrows():

        total, risks = compute_total_risk(row)

        df.loc[i, "total_risk"] = total
        df.loc[i, "available_signals"] = risks["available_signals"]
        df.loc[i, "status"] = risk_to_status(
            total,
            risks["available_signals"]
        )


        df.loc[i, "r_ph"] = risks["ph"]
        df.loc[i, "r_turb"] = risks["turbidity"]
        df.loc[i, "r_orp"] = risks["orp"]
        df.loc[i, "r_rain"] = risks["rainfall"]
        df.loc[i, "r_health"] = risks["health"]

    df.to_csv("data/synthetic_with_risks.csv", index=False)

    print(df[[
        "ph",
        "turbidity",
        "rainfall",
        "diarrhea",
        "vomiting",
        "fever",
        "total_risk",
        "status",
        "r_ph",
        "r_turb",
        "r_rain",
        "r_health"
    ]].head())
