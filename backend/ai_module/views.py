# ai_module/views.py

import joblib
import os
import pandas as pd
from django.conf import settings
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from sentence_transformers import SentenceTransformer
import json

# Initialize the embedding model for use in predictions
embedder = SentenceTransformer('paraphrase-MiniLM-L6-v2')

@csrf_exempt  # For development; adjust for production
def predict_repair_time(request):
    if request.method == "POST":
        try:
            # Parse JSON data
            data = json.loads(request.body)
            description = data.get('description', '')
            make = data.get('make', '')
            model = data.get('model', '')
            year = data.get('year', '')
            engine = data.get('engine', '')

            # Validation check for required fields
            if not (description and make and model and year and engine):
                return JsonResponse({'error': 'Missing fields in request'}, status=400)

            year = int(year)

        except ValueError:
            return JsonResponse({'error': 'Invalid year format'}, status=400)
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)

        # Load the trained model
        model_path = os.path.join(settings.MEDIA_ROOT, 'models/repair_time_model.joblib')
        pipeline = joblib.load(model_path)

        # Convert description to an embedding
        description_embedding = embedder.encode(description).tolist()

        # Prepare input for prediction with embedding and categorical features
        input_data = pd.DataFrame(
            [description_embedding + [make, model, year, engine]], 
            columns=[f'embedding_{i}' for i in range(len(description_embedding))] + ['make', 'model', 'year', 'engine']
        )

        # Add the description column
        input_data['description'] = description

        # Predict repair time
        try:
            predicted_time = pipeline.predict(input_data)[0]
            return JsonResponse({'predicted_time': round(predicted_time, 2)})
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Invalid request method'}, status=405)