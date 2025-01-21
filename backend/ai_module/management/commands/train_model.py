import os
import sys
import django

project_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.append(project_root)
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

import json
import numpy as np
import pandas as pd
from django.utils import timezone
from django.db.models import Sum, Avg, Max, Min
from django.core.management.base import BaseCommand
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import StratifiedKFold, GridSearchCV
from sklearn.metrics import classification_report, confusion_matrix
from imblearn.over_sampling import SMOTE
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
import matplotlib.pyplot as plt
import seaborn as sns
import joblib

class Command(BaseCommand):
    help = 'Trenuje model klasyfikacji klientów'

    def handle(self, *args, **kwargs):
        def prepare_dataset():
            from clients.models import Client
            self.stdout.write(self.style.NOTICE("Rozpoczęto przygotowanie danych..."))
            clients = Client.objects.exclude(segment__isnull=True)
            today = timezone.now().date()
            data = []

            for client in clients:
                try:
                    appointments = client.appointments.all()
                    completed_appointments = appointments.filter(status='completed')
                    canceled_appointments = appointments.filter(status='canceled')

                    frequency = completed_appointments.count()
                    monetary_value = completed_appointments.aggregate(total_spent=Sum('total_cost'))['total_spent'] or 0
                    avg_cost = completed_appointments.aggregate(avg_spent=Avg('total_cost'))['avg_spent'] or 0
                    canceled_count = canceled_appointments.count()
                    total_appointments = frequency + canceled_count

                    cancellation_rate = canceled_count / total_appointments if total_appointments > 0 else 0

                    first_appointment_date = completed_appointments.aggregate(first_date=Min('scheduled_time'))['first_date']
                    last_appointment_date = completed_appointments.aggregate(last_date=Max('scheduled_time'))['last_date']

                    recency = (today - last_appointment_date.date()).days if last_appointment_date else (today - client.created_at.date()).days
                    time_since_first_visit = (today - first_appointment_date.date()).days if first_appointment_date else 0

                    vehicles = client.vehicles.all()
                    if vehicles.exists():
                        latest_vehicle = vehicles.order_by('-year').first()
                        vehicle_year = latest_vehicle.year
                        vehicle_mileage = latest_vehicle.mileage
                    else:
                        vehicle_year = None
                        vehicle_mileage = None

                    data.append({
                        'client_id': client.id,
                        'recency': recency,
                        'frequency': frequency,
                        'monetary_value': monetary_value,
                        'avg_cost': avg_cost,
                        'canceled_count': canceled_count,
                        'cancellation_rate': cancellation_rate,
                        'time_since_first_visit': time_since_first_visit,
                        'vehicle_year': vehicle_year,
                        'vehicle_mileage': vehicle_mileage,
                        'segment': client.segment
                    })
                except Exception as e:
                    self.stdout.write(self.style.ERROR(f"Błąd podczas przetwarzania klienta {client.id}: {e}"))

            df = pd.DataFrame(data)
            df['vehicle_year'] = df['vehicle_year'].fillna(df['vehicle_year'].median())
            df['vehicle_mileage'] = df['vehicle_mileage'].fillna(df['vehicle_mileage'].median())

            df['recency'] = df['recency'].fillna(365)
            df['frequency'] = df['frequency'].fillna(0)
            df['monetary_value'] = df['monetary_value'].fillna(0)
            df['avg_cost'] = df['avg_cost'].fillna(0)
            df['canceled_count'] = df['canceled_count'].fillna(0)
            df['cancellation_rate'] = df['cancellation_rate'].fillna(0)
            df['time_since_first_visit'] = df['time_since_first_visit'].fillna(365)

            self.stdout.write(self.style.SUCCESS(f"Przygotowano dane dla {len(data)} klientów"))
            self.stdout.write(self.style.NOTICE(f"Rozkład klas:\n{df['segment'].value_counts()}"))
            return df

        def balance_data(X, y):
            self.stdout.write(self.style.NOTICE("Rozpoczynanie balansowania danych z SMOTE..."))
            smote = SMOTE(random_state=42)
            try:
                X_resampled, y_resampled = smote.fit_resample(X, y)
                self.stdout.write(self.style.SUCCESS("Balansowanie zakończone. SMOTE zastosowano."))
            except Exception as e:
                self.stdout.write(self.style.ERROR(f"Błąd podczas balansowania danych: {e}"))
                raise e

            return X_resampled, y_resampled

        def plot_confusion_matrix(y_true, y_pred, labels, title):
            cm = confusion_matrix(y_true, y_pred, labels=labels)
            plt.figure(figsize=(8,6))
            sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=labels, yticklabels=labels)
            plt.xlabel('Predicted Label')
            plt.ylabel('True Label')
            plt.title(title)
            plt.show()

        def train_advanced_model():
            self.stdout.write(self.style.NOTICE("Rozpoczęto trening modelu..."))
            df = prepare_dataset()

            features = ['recency', 'frequency', 'monetary_value', 'avg_cost', 'canceled_count',
                        'cancellation_rate', 'time_since_first_visit', 'vehicle_year', 'vehicle_mileage']
            X = df[features]
            y = df['segment']
            X = X.fillna(X.median())
            X_balanced, y_balanced = balance_data(X, y)

            pipeline = Pipeline([
                ('scaler', StandardScaler()),
                ('classifier', RandomForestClassifier(random_state=42))
            ])

            param_grid = {
                'classifier__n_estimators': [50, 100, 200],
                'classifier__max_depth': [10, 20, 30],
                'classifier__min_samples_split': [2, 5, 10],
                'classifier__min_samples_leaf': [1, 2, 4]
            }

            grid_search = GridSearchCV(
                pipeline,
                param_grid,
                scoring='accuracy',
                cv=StratifiedKFold(n_splits=5, shuffle=True, random_state=42),
                n_jobs=-1,
                verbose=1
            )

            try:
                grid_search.fit(X_balanced, y_balanced)
                best_model = grid_search.best_estimator_
                self.stdout.write(self.style.SUCCESS(f"Grid Search zakończony. Najlepsze parametry: {grid_search.best_params_}"))
                self.stdout.write(self.style.SUCCESS(f"Najlepsza dokładność w walidacji: {grid_search.best_score_:.2f}"))
            except Exception as e:
                self.stdout.write(self.style.ERROR(f"Błąd podczas Grid Search: {e}"))
                raise e

            y_pred = best_model.predict(X_balanced)
            self.stdout.write(self.style.NOTICE("Raport klasyfikacji:"))
            self.stdout.write(classification_report(y_balanced, y_pred))

            plot_confusion_matrix(y_balanced, y_pred, labels=np.unique(y_balanced), title="Macierz konfuzji")

            model_path = os.path.join(os.path.dirname(__file__), 'advanced_client_segment_classifier.joblib')
            joblib.dump(best_model, model_path)

            metadata = {
                'best_params': grid_search.best_params_,
                'features': features,
                'accuracy': grid_search.best_score_
            }
            metadata_path = os.path.join(os.path.dirname(__file__), 'model_metadata.json')
            with open(metadata_path, 'w') as f:
                json.dump(metadata, f)

            self.stdout.write(self.style.SUCCESS(f"Model zapisano w: {model_path}"))
            self.stdout.write(self.style.SUCCESS(f"Metadane modelu zapisano jako: {metadata_path}"))

        train_advanced_model()
