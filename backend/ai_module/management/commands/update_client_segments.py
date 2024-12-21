import os
import sys
import django
import json
import pandas as pd
from django.utils import timezone
from django.db.models import Sum, Avg, Max, Min
from django.core.management.base import BaseCommand
import joblib
from clients.models import Client
from utils import SEGMENT_DISCOUNTS

class Command(BaseCommand):
    help = 'Aktualizuje segmenty klientów na podstawie modelu ML'

    def handle(self, *args, **kwargs):
        def load_metadata():
            metadata_path = os.path.join(os.path.dirname(__file__), 'model_metadata.json')
            if not os.path.exists(metadata_path):
                raise FileNotFoundError(f"Metadane modelu nie zostały znalezione: {metadata_path}")
            with open(metadata_path, 'r') as f:
                return json.load(f)

        def prepare_features(client, feature_order):
            today = timezone.now().date()
            appointments = client.appointments.filter(status='completed')
            canceled_appointments = client.appointments.filter(status='canceled')

            frequency = appointments.count()
            monetary_value = appointments.aggregate(total_spent=Sum('total_cost'))['total_spent'] or 0
            avg_cost = appointments.aggregate(avg_spent=Avg('total_cost'))['avg_spent'] or 0
            last_appointment_date = appointments.aggregate(last_date=Max('scheduled_time'))['last_date']
            first_appointment_date = appointments.aggregate(first_date=Min('scheduled_time'))['first_date']

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
                vehicle_year = today.year - 10 
                vehicle_mileage = 100000 

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

            # Upewnij się, że cechy są w odpowiedniej kolejności
            feature_values = [features.get(feature, 0) for feature in feature_order]

            # Zamiana brakujących wartości na medianę lub inną wartość domyślną
            for i, value in enumerate(feature_values):
                if pd.isnull(value):
                    if feature_order[i] == 'vehicle_year':
                        feature_values[i] = today.year - 10  # Domyślnie 10-letni pojazd
                    elif feature_order[i] == 'vehicle_mileage':
                        feature_values[i] = 100000          # Domyślny przebieg
                    else:
                        feature_values[i] = 0

            return feature_values

        def update_client_segments():
            model_path = os.path.join(os.path.dirname(__file__), 'advanced_client_segment_classifier.joblib')
            if not os.path.exists(model_path):
                self.stdout.write(self.style.ERROR(f"Model nie został znaleziony pod ścieżką: {model_path}"))
                return

            try:
                model = joblib.load(model_path)
                self.stdout.write(self.style.SUCCESS("Model załadowano poprawnie."))
            except Exception as e:
                self.stdout.write(self.style.ERROR(f"Błąd podczas ładowania modelu: {e}"))
                return

            try:
                metadata = load_metadata()
                feature_order = metadata['features']
                self.stdout.write(self.style.SUCCESS("Metadane modelu załadowano poprawnie."))
            except Exception as e:
                self.stdout.write(self.style.ERROR(f"Błąd podczas ładowania metadanych modelu: {e}"))
                return

            clients = Client.objects.all()
            if not clients.exists():
                self.stdout.write(self.style.WARNING("Brak klientów do aktualizacji."))
                return

            for client in clients:
                try:
                    features = prepare_features(client, feature_order)
                    X_new = pd.DataFrame([features], columns=feature_order)

                    # Uzupełnienie brakujących wartości
                    X_new = X_new.fillna(X_new.median())

                    predicted_segment = model.predict(X_new)[0]
                    client.segment = predicted_segment
                    client.discount = SEGMENT_DISCOUNTS.get(predicted_segment, 0.00)
                    client.save()

                    self.stdout.write(
                        self.style.SUCCESS(f"Zaktualizowano klienta {client.id}: segment={predicted_segment}, discount={client.discount}")
                    )
                except Exception as e:
                    self.stdout.write(self.style.ERROR(f"Błąd podczas aktualizacji klienta {client.id}: {e}"))

        update_client_segments()
