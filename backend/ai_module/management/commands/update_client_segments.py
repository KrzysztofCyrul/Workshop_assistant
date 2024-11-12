import os
import sys
import django

# Ustawienie ścieżki do katalogu głównego projektu
project_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.append(project_root)

# Ustawienie zmiennej środowiskowej
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')  # Zmień 'backend' na nazwę swojego projektu

# Inicjalizacja Django
django.setup()

from django.core.management.base import BaseCommand
from clients.models import Client
from django.utils import timezone
from django.db.models import Sum, Count, Max, Avg
import joblib
import pandas as pd

SEGMENT_DISCOUNTS = {
    'A': 20.00,  # 20% rabatu
    'B': 10.00,  # 10% rabatu
    'C': 5.00,   # 5% rabatu
    'D': 0.00,   # Brak rabatu
}

class Command(BaseCommand):
    help = 'Aktualizuje segmenty klientów na podstawie modelu ML'

    def handle(self, *args, **kwargs):
        def update_client_segments():
            model_path = os.path.join(os.path.dirname(__file__), '..', '..', 'client_segment_classifier.joblib')
            if not os.path.exists(model_path):
                raise FileNotFoundError(f"No such file or directory: '{model_path}'")
            
            model = joblib.load(model_path)
            clients = Client.objects.all()
            today = timezone.now().date()

            for client in clients:
                appointments = client.appointments.filter(status='completed')
                canceled_appointments = client.appointments.filter(status='canceled')

                frequency = appointments.count()
                monetary_value = appointments.aggregate(total_spent=Sum('total_cost'))['total_spent'] or 0
                avg_cost = appointments.aggregate(avg_spent=Avg('total_cost'))['avg_spent'] or 0
                last_appointment_date = appointments.aggregate(last_date=Max('scheduled_time'))['last_date']
                recency = (today - last_appointment_date.date()).days if last_appointment_date else (today - client.created_at.date()).days
                canceled_count = canceled_appointments.count()

                X_new = pd.DataFrame([{
                    'recency': recency,
                    'frequency': frequency,
                    'monetary_value': monetary_value,
                    'avg_cost': avg_cost,
                    'canceled_count': canceled_count,
                }])

                predicted_segment = model.predict(X_new)[0]
                client.segment = predicted_segment
                client.discount = SEGMENT_DISCOUNTS.get(predicted_segment, 0.00)
                client.save()

        update_client_segments()
