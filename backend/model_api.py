from flask_cors import CORS
# Basit bir Flask API ile LSTM modelini kullanarak glikoz tahmini
from flask import Flask, request, jsonify
import numpy as np
import pandas as pd
from tensorflow.keras.models import load_model
import joblib

app = Flask(__name__)
CORS(app)
@app.route('/', methods=['GET'])
def home():
    return 'Glucose Prediction API is running.'

# Model ve scaler'ı yükle
MODEL_PATH = 'lstm_model2.h5'
SCALER_PATH = 'lstm_model2_scaler.pkl'
model = load_model(MODEL_PATH, compile=False)
scaler = joblib.load(SCALER_PATH)

# Modelde kullanılan sütunlar
COLUMNS_NEEDED = ['glucose', 'carb_input', 'bolus_volume_delivered', 'basal_rate', 'steps', 'calories', 'heart_rate']
LOOK_BACK = 12  # Modelinizde kullandığınız look_back ile aynı olmalı

def predict_with_model(input_data):
    # input_data: dict, sadece özellikler (glucose hariç) gelirse glucose=0 olarak eklenir
    # Son 12 zaman adımı için veri beklenir, eksikse dummy ile doldurulur
    df = pd.DataFrame([input_data])
    for col in COLUMNS_NEEDED:
        if col not in df:
            df[col] = 0.0
    # Sadece son LOOK_BACK kadar veriyle tahmin yapılır
    if len(df) < LOOK_BACK:
        dummy = pd.DataFrame(np.zeros((LOOK_BACK - len(df), len(COLUMNS_NEEDED))), columns=COLUMNS_NEEDED)
        df = pd.concat([dummy, df], ignore_index=True)
    features = df[COLUMNS_NEEDED].values[-LOOK_BACK:]
    features_scaled = scaler.transform(features)
    X_pred = np.array([features_scaled])
    y_pred_scaled = model.predict(X_pred)
    # Sadece glucose sütunu için inverse transform
    dummy = np.zeros((1, len(COLUMNS_NEEDED)))
    glucose_col = COLUMNS_NEEDED.index('glucose')
    dummy[:, glucose_col] = y_pred_scaled.flatten()
    y_pred = scaler.inverse_transform(dummy)[:, glucose_col][0]
    return y_pred

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    try:
        prediction = predict_with_model(data)
        return jsonify({'prediction': float(prediction)})
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
