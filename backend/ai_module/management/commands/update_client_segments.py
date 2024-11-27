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

SEGMENT_DISCOUNTS = {
    'A': 10.00,  # 10% rabatu
    'B': 5.00,  # 5% rabatu
    'C': 2.00,   # 2% rabatu
    'D': 0.00,   # Brak rabatu
}

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
                else 0
            )
            canceled_count = canceled_appointments.count()
            cancellation_rate = (
                canceled_count / (frequency + canceled_count)
                if (frequency + canceled_count) > 0
                else 0
            )

            features = {
                'recency': recency,
                'frequency': frequency,
                'monetary_value': monetary_value,
                'avg_cost': avg_cost,
                'canceled_count': canceled_count,
                'time_since_first_visit': time_since_first_visit,
                'cancellation_rate': cancellation_rate,
            }

            # Upewnij się, że cechy są w odpowiedniej kolejności
            return [features[feature] for feature in feature_order]

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
