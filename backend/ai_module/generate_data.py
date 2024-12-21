import os
import joblib
import json
import pandas as pd
import numpy as np
import random
from datetime import datetime, timedelta
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import classification_report, accuracy_score

# Ustawienie ziarna losowości dla powtarzalności wyników
random.seed(42)
np.random.seed(42)

# Definiowanie parametrów generatora
NUM_CLIENTS = 400       # Zwiększono liczbę klientów dla lepszego rozkładu
START_DATE = datetime.now() - timedelta(days=365)  # Data początkowa (rok temu)
END_DATE = datetime.now()                          # Data końcowa (dzisiaj)

# Funkcja do generowania klientów dla poszczególnych segmentów
def generate_clients_for_segment(segment, num_clients):
    clients = []
    appointments = []
    vehicles = []

    for i in range(num_clients):
        client_id = f'client_{segment}_{i+1}'
        created_at = START_DATE + timedelta(days=random.randint(0, 180))  # Dla wszystkich segmentów poza D

        # Generowanie cech dla segmentu A
        if segment == 'A':
            recency = random.randint(0, 30)
            frequency = random.randint(11, 20)
            monetary_value = random.uniform(5001, 10000)
            avg_cost = random.uniform(501, 1000)
            canceled_count = 0
            time_since_first_visit = random.randint(0, 179)
            cancellation_rate = 0
            vehicle_year = random.randint(datetime.now().year - 5, datetime.now().year)
            vehicle_mileage = random.randint(0, 50000)
        # Generowanie cech dla segmentu B
        elif segment == 'B':
            recency = random.randint(31, 90)
            frequency = random.randint(6, 10)
            monetary_value = random.uniform(2001, 5000)
            avg_cost = random.uniform(301, 500)
            canceled_count = random.randint(0, 1)
            time_since_first_visit = random.randint(90, 180)
            cancellation_rate = random.uniform(0, 0.19)
            vehicle_year = random.randint(datetime.now().year - 10, datetime.now().year - 5)
            vehicle_mileage = random.randint(50001, 100000)
        # Generowanie cech dla segmentu C
        elif segment == 'C':
            recency = random.randint(91, 180)
            frequency = random.randint(1, 5)
            monetary_value = random.uniform(1001, 2000)
            avg_cost = random.uniform(201, 300)
            canceled_count = random.randint(0, 2)
            time_since_first_visit = random.randint(180, 365)
            cancellation_rate = random.uniform(0, 0.29)
            vehicle_year = random.randint(datetime.now().year - 20, datetime.now().year - 10)
            vehicle_mileage = random.randint(100001, 200000)
        # Generowanie cech dla segmentu D
        else:  # Segment D
            recency = random.randint(181, 365)
            frequency = random.randint(0, 5)
            monetary_value = random.uniform(0, 1000)
            avg_cost = random.uniform(0, 200)
            canceled_count = random.randint(0, 5)
            time_since_first_visit = random.randint(180, 365)
            cancellation_rate = random.uniform(0.3, 1)
            vehicle_year = random.randint(1990, datetime.now().year - 20)
            vehicle_mileage = random.randint(150001, 300000)

        clients.append({'client_id': client_id, 'created_at': created_at})

        vehicles.append({
            'client_id': client_id,
            'vehicle_year': vehicle_year,
            'vehicle_mileage': vehicle_mileage
        })

        # Generowanie wizyt na podstawie częstotliwości
        num_visits = frequency + canceled_count
        for _ in range(num_visits):
            appointment_date = END_DATE - timedelta(days=random.randint(recency, recency + 30))
            if appointment_date < created_at:
                appointment_date = created_at + timedelta(days=random.randint(0, 30))
            total_cost = avg_cost
            is_canceled = canceled_count > 0 and random.random() < cancellation_rate
            status = 'canceled' if is_canceled else 'completed'
            appointments.append({
                'client_id': client_id,
                'appointment_date': appointment_date,
                'total_cost': total_cost if not is_canceled else 0,
                'status': status
            })

    return pd.DataFrame(clients), pd.DataFrame(vehicles), pd.DataFrame(appointments)

# Główna funkcja generatora
def generate_data(num_clients_per_segment=100):
    clients_list = []
    vehicles_list = []
    appointments_list = []

    segments = ['A', 'B', 'C', 'D']

    for segment in segments:
        clients_df, vehicles_df, appointments_df = generate_clients_for_segment(segment, num_clients_per_segment)
        clients_list.append(clients_df)
        vehicles_list.append(vehicles_df)
        appointments_list.append(appointments_df)

    clients_df = pd.concat(clients_list, ignore_index=True)
    vehicles_df = pd.concat(vehicles_list, ignore_index=True)
    appointments_df = pd.concat(appointments_list, ignore_index=True)

    # Obliczanie cech i przypisywanie segmentów
    features = calculate_features(clients_df, appointments_df, vehicles_df)
    features = assign_segments(features)

    return features, appointments_df

# Funkcja calculate_features
def calculate_features(clients_df, appointments_df, vehicles_df):
    today = datetime.now()
    completed_appointments = appointments_df[appointments_df['status'] == 'completed']

    # Obliczanie Recency
    last_purchase = completed_appointments.groupby('client_id')['appointment_date'].max().reset_index()
    last_purchase.columns = ['client_id', 'last_purchase_date']
    last_purchase['recency'] = (today - last_purchase['last_purchase_date']).dt.days

    # Obliczanie Frequency
    frequency = completed_appointments.groupby('client_id').size().reset_index(name='frequency')

    # Obliczanie Monetary Value
    monetary = completed_appointments.groupby('client_id')['total_cost'].sum().reset_index()
    monetary.columns = ['client_id', 'monetary_value']

    # Obliczanie Average Cost
    avg_cost = completed_appointments.groupby('client_id')['total_cost'].mean().reset_index()
    avg_cost.columns = ['client_id', 'avg_cost']

    # Obliczanie liczby anulowanych wizyt
    canceled_appointments = appointments_df[appointments_df['status'] == 'canceled']
    canceled_count = canceled_appointments.groupby('client_id').size().reset_index(name='canceled_count')

    # Obliczanie czasu od pierwszej wizyty
    first_appointment = completed_appointments.groupby('client_id')['appointment_date'].min().reset_index()
    first_appointment.columns = ['client_id', 'first_appointment_date']
    first_appointment['time_since_first_visit'] = (today - first_appointment['first_appointment_date']).dt.days

    # Scalanie danych
    features = clients_df.merge(last_purchase[['client_id', 'recency']], on='client_id', how='left')
    features = features.merge(frequency, on='client_id', how='left')
    features = features.merge(monetary, on='client_id', how='left')
    features = features.merge(avg_cost, on='client_id', how='left')
    features = features.merge(canceled_count, on='client_id', how='left')
    features = features.merge(first_appointment[['client_id', 'time_since_first_visit']], on='client_id', how='left')

    # Uzupełnianie braków dla klientów bez wizyt
    features['recency'] = features['recency'].fillna(365)
    features['frequency'] = features['frequency'].fillna(0)
    features['monetary_value'] = features['monetary_value'].fillna(0)
    features['avg_cost'] = features['avg_cost'].fillna(0)
    features['canceled_count'] = features['canceled_count'].fillna(0)
    features['time_since_first_visit'] = features['time_since_first_visit'].fillna(365)

    # Obliczanie wskaźnika anulowanych wizyt
    features['cancellation_rate'] = features['canceled_count'] / (features['frequency'] + features['canceled_count'])
    features['cancellation_rate'] = features['cancellation_rate'].fillna(0)

    # Dodanie danych pojazdów
    features = features.merge(vehicles_df, on='client_id', how='left')

    return features

def assign_segments(features):
    def segment_rfm(row):
        # Warunki dla segmentu A
        if (row['recency'] <= 30 and
            row['frequency'] > 10 and
            row['monetary_value'] > 5000 and
            row['avg_cost'] > 500 and
            row['canceled_count'] == 0 and
            row['time_since_first_visit'] < 180 and
            row['cancellation_rate'] < 0.1 and
            row['vehicle_year'] >= datetime.now().year - 5 and
            row['vehicle_mileage'] <= 50000):
            return 'A'
        # Warunki dla segmentu B
        elif (row['recency'] <= 90 and
              row['frequency'] > 5 and
              row['monetary_value'] > 2000 and
              row['avg_cost'] > 300 and
              row['cancellation_rate'] < 0.2 and
              row['vehicle_year'] >= datetime.now().year - 10 and
              row['vehicle_mileage'] <= 100000):
            return 'B'
        # Warunki dla segmentu C
        elif (row['recency'] <= 180 and
              row['monetary_value'] > 1000 and
              row['avg_cost'] > 200 and
              row['cancellation_rate'] < 0.3 and
              row['vehicle_mileage'] > 100000):
            return 'C'
        # Segment D dla pozostałych klientów
        else:
            return 'D'
    features['segment'] = features.apply(segment_rfm, axis=1)
    return features

# Uruchomienie generatora
rfm_df, appointments_df = generate_data()

print("Przykładowe dane RFM:")
print(rfm_df.head())

print("\nRozkład segmentów:")
print(rfm_df['segment'].value_counts())

# Trening i ewaluacja modelu
features_list = ['recency', 'frequency', 'monetary_value', 'avg_cost', 'canceled_count',
                 'time_since_first_visit', 'cancellation_rate', 'vehicle_year', 'vehicle_mileage']
X = rfm_df[features_list]
y = rfm_df['segment']

# Podział na zbiór treningowy i testowy
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.3, stratify=y, random_state=42)

# Trening modelu
model = DecisionTreeClassifier(random_state=42)
model.fit(X_train, y_train)

# Ewaluacja modelu
y_pred = model.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)
print("\nRaport klasyfikacji:")
print(classification_report(y_test, y_pred))

# Zapisanie modelu
model_path = 'advanced_client_segment_classifier.joblib'
joblib.dump(model, model_path)
print(f"\nModel zapisano jako '{model_path}'")

# Zapisanie metadanych
metadata = {
    'features': features_list,
    'best_params': None,  # W DecisionTreeClassifier brak optymalizacji parametrów
    'accuracy': accuracy
}
metadata_path = 'model_metadata.json'
with open(metadata_path, 'w') as f:
    json.dump(metadata, f, indent=4)
print(f"Metadane zapisano jako '{metadata_path}'")
