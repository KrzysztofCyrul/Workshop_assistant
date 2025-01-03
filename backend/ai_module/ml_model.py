import os
import sys
import django

if __name__ == '__main__':
    # Set up Django environment for standalone script
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sys.path.append(project_root)
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
    django.setup()
    
from django.db.models.signals import post_save
from django.dispatch import receiver
from clients.models import Client
from appointments.models import Appointment
from django.db.models import Sum, Avg, Max, Min
import os
import json
import pandas as pd
import joblib
from django.utils.timezone import now
from ai_module.utils import SEGMENT_DISCOUNTS

# Funkcja do przewidywania segmentu na podstawie modelu ML
def predict_segment(client):
    try:
        # Załaduj model ML
        model_path = os.path.join(os.path.dirname(__file__), 'management', 'commands', 'advanced_client_segment_classifier.joblib')
        metadata_path = os.path.join(os.path.dirname(__file__), 'management', 'commands', 'model_metadata.json')
        
        if not os.path.exists(model_path) or not os.path.exists(metadata_path):
            raise FileNotFoundError("Model lub metadane nie zostały znalezione")

        model = joblib.load(model_path)
        with open(metadata_path, 'r') as f:
            metadata = json.load(f)
        feature_order = metadata['features']

        # Przygotowanie cech klienta
        appointments = client.appointments.filter(status='completed')
        canceled_appointments = client.appointments.filter(status='canceled')

        frequency = appointments.count()
        monetary_value = appointments.aggregate(total_spent=Sum('total_cost'))['total_spent'] or 0
        avg_cost = appointments.aggregate(avg_spent=Avg('total_cost'))['avg_spent'] or 0
        last_appointment_date = appointments.aggregate(last_date=Max('scheduled_time'))['last_date']
        first_appointment_date = appointments.aggregate(first_date=Min('scheduled_time'))['first_date']

        today = now().date()
        recency = (
            (today - last_appointment_date.date()).days
            if last_appointment_date
            else (today - client.created_at.date()).days
        )
        time_since_first_visit = (
            (today - first_appointment_date.date()).days
            if first_appointment_date
            else 365  # Używamy 365 jako domyślnej wartości
        )
        canceled_count = canceled_appointments.count()
        total_appointments = frequency + canceled_count
        cancellation_rate = (
            canceled_count / total_appointments
            if total_appointments > 0
            else 0
        )

        # Pobieranie danych o pojeździe
        vehicles = client.vehicles.all()
        if vehicles.exists():
            latest_vehicle = vehicles.order_by('-year').first()
            vehicle_year = latest_vehicle.year
            vehicle_mileage = latest_vehicle.mileage
        else:
            # Ustawiamy domyślne wartości, jeśli klient nie ma pojazdu
            vehicle_year = today.year - 10  # Domyślnie 10-letni pojazd
            vehicle_mileage = 100000        # Domyślny przebieg

        # Tworzenie wektora cech w odpowiedniej kolejności
        features = {
            'recency': recency,
            'frequency': frequency,
            'monetary_value': monetary_value,
            'avg_cost': avg_cost,
            'canceled_count': canceled_count,
            'cancellation_rate': cancellation_rate,
            'time_since_first_visit': time_since_first_visit,
            'vehicle_year': vehicle_year,
            'vehicle_mileage': vehicle_mileage,
        }

        # Upewnienie się, że cechy są w odpowiedniej kolejności
        feature_values = [features.get(feature, 0) for feature in feature_order]

        # Zamiana brakujących wartości na domyślne
        for i, value in enumerate(feature_values):
            if pd.isnull(value):
                if feature_order[i] == 'vehicle_year':
                    feature_values[i] = today.year - 10  # Domyślnie 10-letni pojazd
                elif feature_order[i] == 'vehicle_mileage':
                    feature_values[i] = 100000          # Domyślny przebieg
                else:
                    feature_values[i] = 0

        X_new = pd.DataFrame([feature_values], columns=feature_order)

        # Uzupełnienie brakujących wartości
        X_new = X_new.fillna(X_new.median())

        # Predykcja segmentu
        predicted_segment = model.predict(X_new)[0]
        return predicted_segment

    except Exception as e:
        print(f"Błąd podczas przewidywania segmentu: {e}")
        return None

@receiver(post_save, sender=Appointment)
def update_client_segment(sender, instance, **kwargs):
    # Obsługuj tylko wizyty zakończone
    if instance.status == 'completed':
        client = instance.client
        previous_segment = client.segment

        # Przewidywanie nowego segmentu
        predicted_segment = predict_segment(client)
        if predicted_segment:
            client.segment = predicted_segment
            client.discount = SEGMENT_DISCOUNTS.get(predicted_segment, 0.00)
            client.save()

            # Informacja o zmianie segmentu
            if predicted_segment != previous_segment:
                print(f"Segment klienta {client.id} zmieniony z {previous_segment} na {predicted_segment}")
