import joblib
import subprocess
import sys
import os
import numpy as np
from config.paths_config import MODEL_OUTPUT_PATH
from flask import Flask, render_template, request

app = Flask(__name__)

loaded_model = joblib.load(MODEL_OUTPUT_PATH)

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':

        lead_time = int(request.form["lead_time"]) # from id of the input
        no_of_special_requests = int(request.form['no_of_special_requests'])
        avg_price_per_room = float(request.form['avg_price_per_room'])
        arrival_month = int(request.form['arrival_month'])
        arrival_date = int(request.form['arrival_date'])
        market_segment_type = int(request.form['market_segment_type'])
        no_of_week_nights = int(request.form['no_of_week_nights'])
        no_of_weekend_nights = int(request.form['no_of_weekend_nights'])
        type_of_meal_plan = int(request.form['type_of_meal_plan'])
        room_type_reserved = int(request.form['room_type_reserved'])


        features = np.array([[lead_time, no_of_special_requests, avg_price_per_room, arrival_month, arrival_date, market_segment_type, 
                              no_of_week_nights, no_of_weekend_nights, type_of_meal_plan, room_type_reserved]])
        
        prediction = loaded_model.predict(features)

        return render_template('index.html', prediction = prediction[0])
    return render_template('index.html', prediction=None)

#!/usr/bin/env python3
"""
Startup script that runs training pipeline first, then starts the Flask application.
"""

def main():
    print("=== Starting ML Pipeline ===")
    
    # Check if model already exists (skip training in production)
    from config.paths_config import MODEL_OUTPUT_PATH
    
    if os.path.exists(MODEL_OUTPUT_PATH):
        print(f"Model already exists at {MODEL_OUTPUT_PATH}")
        print("Skipping training and starting application...")
    else:
        print("Model not found. Running training pipeline...")
        
        # Run training pipeline
        training_result = subprocess.run([
            sys.executable, "pipeline/training_pipeline.py"
        ], capture_output=True, text=True)
        
        if training_result.returncode != 0:
            print("❌ Training failed!")
            print("STDOUT:", training_result.stdout)
            print("STDERR:", training_result.stderr)
            sys.exit(1)
        
        print("✅ Training completed successfully!")
        print("Training output:", training_result.stdout)
    
    # Start the Flask application
    print("=== Starting Flask Application ===")
    app.run(host='0.0.0.0', port=8080)

if __name__ == "__main__":
    main()
