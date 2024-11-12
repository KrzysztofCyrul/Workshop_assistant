import os
import sys
import django

if __name__ == '__main__':
    # Set up Django environment for standalone script
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sys.path.append(project_root)
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
    django.setup()
    
from clients.models import Client
from django.utils import timezone
from django.db.models import Sum, Count, Max, Avg
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
import joblib
import pandas as pd

SEGMENT_DISCOUNTS = {
    'A': 20.00,  # 20% rabatu
    'B': 10.00,  # 10% rabatu
    'C': 5.00,   # 5% rabatu
    'D': 0.00,   # Brak rabatu
}

def predict_segment(client):
    # Ustal ścieżkę do pliku modelu
    current_dir = os.path.dirname(os.path.abspath(__file__))
    model_path = os.path.join(current_dir, 'client_segment_classifier.joblib')
    
    # Wczytanie modelu
    model = joblib.load(model_path)
    
    # Przygotowanie danych klienta
    appointments = client.appointments.all()
    completed_appointments = appointments.filter(status='completed')
    canceled_appointments = appointments.filter(status='canceled')
    today = timezone.now().date()
    
    if completed_appointments.exists():
        frequency = completed_appointments.count()
        monetary_value = completed_appointments.aggregate(total_spent=Sum('total_cost'))['total_spent'] or 0
        avg_cost = completed_appointments.aggregate(avg_cost=Avg('total_cost'))['avg_cost'] or 0
        last_appointment_date = completed_appointments.aggregate(last_date=Max('scheduled_time'))['last_date'].date()
        recency = (today - last_appointment_date).days
    else:
        frequency = 0
        monetary_value = 0
        avg_cost = 0
        recency = 365  # Ustaw wysokie recency dla klientów bez wizyt
    
    canceled_count = canceled_appointments.count()
    
    X_new = pd.DataFrame([{
        'recency': recency,
        'frequency': frequency,
        'monetary_value': monetary_value,
        'avg_cost': avg_cost,
        'canceled_count': canceled_count
    }])
    
    # Przewidywanie segmentu
    predicted_segment = model.predict(X_new)[0]
    return predicted_segment

def update_client_segments():
    model = joblib.load('client_segment_classifier.joblib')
    clients = Client.objects.all()
    for client in clients:
        predicted_segment = predict_segment(client)
        client.segment = predicted_segment
        client.discount = SEGMENT_DISCOUNTS.get(predicted_segment, 0.00)
        client.save()
