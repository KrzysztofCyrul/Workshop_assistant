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
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
import joblib
import pandas as pd

# Jeśli używasz oversamplingu
from imblearn.over_sampling import SMOTE

SEGMENT_DISCOUNTS = {
    'A': 20.00,  # 20% rabatu
    'B': 10.00,  # 10% rabatu
    'C': 5.00,   # 5% rabatu
    'D': 0.00,   # Brak rabatu
}

class Command(BaseCommand):
    help = 'Trenuje model klasyfikacji klientów'

    def handle(self, *args, **kwargs):
        def prepare_dataset():
            clients = Client.objects.exclude(segment__isnull=True)
            data = []
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

                data.append({
                    'client_id': client.id,
                    'recency': recency,
                    'frequency': frequency,
                    'monetary_value': monetary_value,
                    'avg_cost': avg_cost,
                    'canceled_count': canceled_count,
                    'segment': client.segment
                })

            df = pd.DataFrame(data)
            print("Rozkład klas:")
            print(df['segment'].value_counts())
            return df

        def balance_data(X, y):
            # Użyj prostego oversamplingu
            df = pd.concat([X, y], axis=1)
            max_size = df['segment'].value_counts().max()
            lst = [df]
            for class_index, group in df.groupby('segment'):
                lst.append(group.sample(max_size - len(group), replace=True))
            df_new = pd.concat(lst)
            X_new = df_new.drop('segment', axis=1)
            y_new = df_new['segment']
            return X_new, y_new

        def train_model():
            df = prepare_dataset()
            features = ['recency', 'frequency', 'monetary_value', 'avg_cost', 'canceled_count']
            X = df[features]
            y = df['segment']

            # Zbalansowanie danych
            X_balanced, y_balanced = balance_data(X, y)

            # Podział na zbiory treningowy i testowy
            X_train, X_test, y_train, y_test = train_test_split(
                X_balanced, y_balanced, test_size=0.4, stratify=y_balanced, random_state=42
            )

            print("Training set class distribution:")
            print(y_train.value_counts())
            print("Test set class distribution:")
            print(y_test.value_counts())

            # Trening modelu drzewa decyzyjnego
            model = DecisionTreeClassifier(random_state=42)
            model.fit(X_train, y_train)

            # Ewaluacja modelu
            y_pred = model.predict(X_test)
            from sklearn.metrics import classification_report
            print(classification_report(y_test, y_pred))

            # Zapisanie modelu
            joblib.dump(model, os.path.join(os.path.dirname(__file__), 'client_segment_classifier.joblib'))

        train_model()