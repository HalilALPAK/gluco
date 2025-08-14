import requests
from googletrans import Translator

API_KEY = "wJ0z6zM96HdK8Sxfpbt2oGtsS93KRtApbTZctNxT"

from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
from googletrans import Translator

API_KEY = "wJ0z6zM96HdK8Sxfpbt2oGtsS93KRtApbTZctNxT"
translator = Translator()

app = Flask(__name__)
CORS(app)

def turkce_to_english(text):
    result = translator.translate(text, src='tr', dest='en')
    return result.text

def english_to_turkish(text):
    result = translator.translate(text, src='en', dest='tr')
    return result.text

def search_foods(query):
    url = f"https://api.nal.usda.gov/fdc/v1/foods/search?api_key={API_KEY}&query={query}&pageSize=1"
    response = requests.get(url)
    data = response.json()
    if "foods" in data and data["foods"]:
        return data["foods"][0]
    else:
        return None

def get_nutrient_info(food):
    nutrients = food.get("foodNutrients", [])
    info = {}
    for nutrient in nutrients:
        name = nutrient.get("nutrientName")
        amount = nutrient.get("value")
        unit = nutrient.get("unitName")
        if name and amount is not None:
            turkce_adi = english_to_turkish(name)
            info[turkce_adi] = f"{amount} {unit}"
    return info

@app.route('/get_nutrients', methods=['POST'])
def get_nutrients():
    data = request.get_json()
    turkce_yemek = data.get('food_name', '')
    if not turkce_yemek:
        return jsonify({'error': 'food_name is required'}), 400
    try:
        ingilizce_yemek = turkce_to_english(turkce_yemek)
        food = search_foods(ingilizce_yemek)
        if food:
            nutrients = get_nutrient_info(food)
            return jsonify({
                'food': food['description'],
                'nutrients': nutrients
            })
        else:
            return jsonify({'error': 'Food not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=True)

import requests
from googletrans import Translator
import numpy as np
import tensorflow as tf
import joblib

API_KEY = "wJ0z6zM96HdK8Sxfpbt2oGtsS93KRtApbTZctNxT"
translator = Translator()


app = Flask(__name__)
CORS(app, supports_credentials=True, resources={r"/*": {"origins": "*"}})

# Ana sayfa: API durumu
@app.route('/', methods=['GET'])
def home():
    return 'Glucose Prediction API is running.'

# LSTM model ve scaler yükle
MODEL_PATH = 'lstm_model2.h5'
SCALER_PATH = 'lstm_model2_scaler.pkl'
lstm_model = tf.keras.models.load_model(MODEL_PATH)
scaler = joblib.load(SCALER_PATH)
@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    # Gerekli inputları al
    carb = data.get('carb_input', 0)
    steps = data.get('steps', 0)
    calories = data.get('calories', 0)
    heart_rate = data.get('heart_rate', 0)
    bolus = data.get('bolus_volume_delivered', 0)
    basal = data.get('basal_rate', 0)

    # Sıralama: [carb_input, steps, calories, heart_rate, bolus_volume_delivered, basal_rate]
    X = np.array([[carb, steps, calories, heart_rate, bolus, basal]])
    X_scaled = scaler.transform(X)
    # LSTM için 3D shape: (batch, timesteps, features)
    X_lstm = np.reshape(X_scaled, (X_scaled.shape[0], 1, X_scaled.shape[1]))
    prediction = lstm_model.predict(X_lstm)
    # Çıktı tek değer ise düzleştir
    if prediction.shape[-1] == 1:
        prediction = prediction.flatten()[0]
    else:
        prediction = float(prediction[0][0])
    return jsonify({'prediction': prediction})

def turkce_to_english(text):
    result = translator.translate(text, src='tr', dest='en')
    return result.text

def english_to_turkish(text):
    result = translator.translate(text, src='en', dest='tr')
    return result.text

def search_foods(query):
    url = f"https://api.nal.usda.gov/fdc/v1/foods/search?api_key={API_KEY}&query={query}&pageSize=1"
    response = requests.get(url)
    data = response.json()
    if "foods" in data and data["foods"]:
        return data["foods"][0]
    else:
        return None

def get_nutrient_info(food):
    nutrients = food.get("foodNutrients", [])
    info = {}
    for nutrient in nutrients:
        name = nutrient.get("nutrientName")
        amount = nutrient.get("value")
        unit = nutrient.get("unitName")
        if name and amount is not None:
            turkce_adi = english_to_turkish(name)
            info[turkce_adi] = f"{amount} {unit}"
    return info

@app.route('/get_nutrients', methods=['POST'])
def get_nutrients():
    data = request.get_json()
    turkce_yemek = data.get('yemek')
    if not turkce_yemek:
        return jsonify({'error': 'Yemek adı gerekli!'}), 400
    ingilizce_yemek = turkce_to_english(turkce_yemek)
    food = search_foods(ingilizce_yemek)
    if food:
        nutrients = get_nutrient_info(food)
        return jsonify({
            'description': food['description'],
            'nutrients': nutrients
        })
    else:
        return jsonify({'error': 'Yemek bulunamadı!'}), 404

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
