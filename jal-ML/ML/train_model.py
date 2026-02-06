import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestClassifier
import joblib
import os

def train():
    # Load data
    data_path = os.path.join(os.path.dirname(__file__), "data", "synthetic_with_risks.csv")
    if not os.path.exists(data_path):
        print(f"Data not found at {data_path}")
        return

    df = pd.read_csv(data_path)

    features = [
        "ph",
        "turbidity",
        "orp",
        "rainfall",
        "diarrhea",
        "vomiting",
        "fever"
    ]

    # Drop rows with missing features or status
    df = df.dropna(subset=features + ["status"])

    X = df[features]
    y = df["status"]

    le = LabelEncoder()
    y_enc = le.fit_transform(y)

    # Train model
    model = RandomForestClassifier(
        n_estimators=200,
        random_state=42
    )
    model.fit(X, y_enc)

    # Save model, label encoder and features list
    model_dir = os.path.join(os.path.dirname(__file__), "trained_model")
    os.makedirs(model_dir, exist_ok=True)
    
    joblib.dump(model, os.path.join(model_dir, "model.joblib"))
    joblib.dump(le, os.path.join(model_dir, "label_encoder.joblib"))
    joblib.dump(features, os.path.join(model_dir, "features.joblib"))

    print(f"Model trained and saved to {model_dir}")

if __name__ == "__main__":
    train()
