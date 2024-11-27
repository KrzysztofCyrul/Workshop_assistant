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
NUM_CLIENTS = 300       # Liczba klientów
MAX_VISITS = 20         # Przywrócona maksymalna liczba wizyt
MIN_COST = 20           # Minimalny koszt wizyty
MAX_COST = 2000         # Maksymalna liczba koszt wizyty
CANCEL_PROBABILITY = 0.3 # Zmniejszone prawdopodobieństwo odwołania wizyty
START_DATE = datetime.now() - timedelta(days=365)  # Data początkowa (rok temu)
END_DATE = datetime.now()                          # Data końcowa (dzisiaj)

# Funkcja do generowania klientów
def generate_clients(num_clients):
    clients = []
    for i in range(num_clients):
        client_id = f'client_{i+1}'
        created_at = START_DATE + timedelta(days=random.randint(0, 365))
        clients.append({'client_id': client_id, 'created_at': created_at})
    return pd.DataFrame(clients)

# Funkcja do generowania wizyt
def generate_appointments(clients_df):
    appointments = []
    for _, client in clients_df.iterrows():
        num_visits = random.randint(0, MAX_VISITS)
        for _ in range(num_visits):
            appointment_date = client['created_at'] + timedelta(days=random.randint(0, 365))
            if appointment_date > END_DATE:
                break
            total_cost = random.uniform(MIN_COST, MAX_COST)
            is_canceled = random.random() < CANCEL_PROBABILITY
            status = 'canceled' if is_canceled else 'completed'
            appointments.append({
                'client_id': client['client_id'],
                'appointment_date': appointment_date,
                'total_cost': total_cost if not is_canceled else 0,
                'status': status
            })
    return pd.DataFrame(appointments)

# Funkcja do obliczania cech RFM i dodatkowych cech
def calculate_features(clients_df, appointments_df):
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

    return features

# Funkcja do przypisywania segmentów
def assign_segments(features):
    def segment_rfm(row):
        if row['recency'] <= 30 and row['frequency'] > 10:
            return 'A'
        elif row['recency'] <= 90 and row['frequency'] > 5:
            return 'B'
        elif row['recency'] <= 180 and row['monetary_value'] > 1000:
            return 'C'  # Zmieniono 'or' na 'and'
        else:
            return 'D'
    features['segment'] = features.apply(segment_rfm, axis=1)
    return features

# Główna funkcja generatora
def generate_data(num_clients=NUM_CLIENTS):
    clients_df = generate_clients(num_clients)
    appointments_df = generate_appointments(clients_df)
    features = calculate_features(clients_df, appointments_df)
    features = assign_segments(features)
    return features, appointments_df

# Uruchomienie generatora
rfm_df, appointments_df = generate_data()

print("Przykładowe dane RFM:")
print(rfm_df.head())

print("\nRozkład segmentów:")
print(rfm_df['segment'].value_counts())

# Trening i ewaluacja modelu
features = ['recency', 'frequency', 'monetary_value', 'avg_cost', 'canceled_count', 'time_since_first_visit', 'cancellation_rate']
X = rfm_df[features]
y = rfm_df['segment']

# Podział na zbiór treningowy i testowy
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, stratify=y, random_state=42)

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
    'features': features,
    'best_params': None,  # W DecisionTreeClassifier brak optymalizacji parametrów
    'accuracy': accuracy
}
metadata_path = 'model_metadata.json'
with open(metadata_path, 'w') as f:
    json.dump(metadata, f, indent=4)
print(f"Metadane zapisano jako '{metadata_path}'")
