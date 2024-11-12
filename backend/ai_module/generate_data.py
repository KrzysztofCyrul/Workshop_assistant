import os
import sys
import django

# Ustawienie ścieżki do katalogu głównego projektu
project_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.append(project_root)

# Ustawienie zmiennej środowiskowej
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')  # Zmień 'backend' na nazwę swojego projektu

import joblib
import pandas as pd
import numpy as np
import random
from datetime import datetime, timedelta
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import classification_report

# Ustawienie ziarna losowości dla powtarzalności wyników
random.seed(42)
np.random.seed(42)

# Definiowanie parametrów generatora
NUM_CLIENTS = 1000       # Liczba klientów
MAX_VISITS = 20          # Maksymalna liczba wizyt
MIN_COST = 100           # Minimalny koszt wizyty
MAX_COST = 2000          # Maksymalny koszt wizyty
CANCEL_PROBABILITY = 0.2 # Prawdopodobieństwo odwołania wizyty
START_DATE = datetime.now() - timedelta(days=365)  # Data początkowa (rok temu)
END_DATE = datetime.now()                          # Data końcowa (dzisiaj)

# Funkcja do generowania klientów
def generate_clients(num_clients):
    clients = []
    for i in range(num_clients):
        client_id = f'client_{i+1}'
        clients.append({'client_id': client_id})
    return pd.DataFrame(clients)

# Funkcja do generowania wizyt
def generate_appointments(clients_df):
    appointments = []
    for _, client in clients_df.iterrows():
        num_visits = random.randint(0, MAX_VISITS)
        base_cost = random.uniform(MIN_COST, MAX_COST)
        for _ in range(num_visits):
            appointment_date = START_DATE + timedelta(days=random.randint(0, 365))
            # Koszt wizyty może być związany z liczbą wizyt
            total_cost = base_cost * (1 + random.uniform(-0.2, 0.2))
            # Decyzja o odwołaniu wizyty
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
def calculate_rfm(clients_df, appointments_df):
    today = datetime.now()
    
    # Filtrujemy wizyty zakończone
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
    
    # Obliczanie liczby odwołanych wizyt
    canceled_appointments = appointments_df[appointments_df['status'] == 'canceled']
    canceled_count = canceled_appointments.groupby('client_id').size().reset_index(name='canceled_count')
    
    # Scalanie danych
    rfm = clients_df.merge(last_purchase[['client_id', 'recency']], on='client_id', how='left')
    rfm = rfm.merge(frequency, on='client_id', how='left')
    rfm = rfm.merge(monetary, on='client_id', how='left')
    rfm = rfm.merge(avg_cost, on='client_id', how='left')
    rfm = rfm.merge(canceled_count, on='client_id', how='left')
    
    # Uzupełnianie braków dla klientów bez wizyt
    rfm['recency'] = rfm['recency'].fillna(365)
    rfm['frequency'] = rfm['frequency'].fillna(0)
    rfm['monetary_value'] = rfm['monetary_value'].fillna(0)
    rfm['avg_cost'] = rfm['avg_cost'].fillna(0)
    rfm['canceled_count'] = rfm['canceled_count'].fillna(0)
    
    return rfm

# Funkcja do przypisywania ocen RFM
def assign_rfm_scores(rfm):
    # Odwracamy recency: im większa wartość, tym niższa ocena
    rfm['R_score'] = pd.qcut(rfm['recency'], 4, labels=[4, 3, 2, 1]).astype(int)
    rfm['F_score'] = pd.qcut(rfm['frequency'].rank(method='first'), 4, labels=[1, 2, 3, 4]).astype(int)
    rfm['M_score'] = pd.qcut(rfm['monetary_value'], 4, labels=[1, 2, 3, 4]).astype(int)
    rfm['RFM_score'] = rfm['R_score'] + rfm['F_score'] + rfm['M_score']
    return rfm

# Funkcja do przypisywania segmentów
def assign_segments(rfm):
    def segment_rfm(row):
        if row['RFM_score'] >= 10:
            return 'A'
        elif row['RFM_score'] >= 7:
            return 'B'
        elif row['RFM_score'] >= 4:
            return 'C'
        else:
            return 'D'
    rfm['segment'] = rfm.apply(segment_rfm, axis=1)
    return rfm

# Główna funkcja generatora
def generate_data(num_clients=NUM_CLIENTS):
    clients_df = generate_clients(num_clients)
    appointments_df = generate_appointments(clients_df)
    rfm = calculate_rfm(clients_df, appointments_df)
    rfm = assign_rfm_scores(rfm)
    rfm = assign_segments(rfm)
    return rfm, appointments_df

# Uruchomienie generatora i sprawdzenie wyników
rfm_df, appointments_df = generate_data()

print("Przykładowe dane RFM:")
print(rfm_df.head())

print("\nRozkład segmentów:")
print(rfm_df['segment'].value_counts())

# Przykład użycia danych w modelu
# Definicja cech i etykiet
features = ['recency', 'frequency', 'monetary_value', 'avg_cost', 'canceled_count']
X = rfm_df[features]
y = rfm_df['segment']

# Podział na zbiór treningowy i testowy
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, stratify=y, random_state=42)

# Trening modelu
model = DecisionTreeClassifier(random_state=42)
model.fit(X_train, y_train)

# Ewaluacja modelu
y_pred = model.predict(X_test)
print("\nRaport klasyfikacji:")
print(classification_report(y_test, y_pred))

# Zapisanie modelu
joblib.dump(model, 'client_segment_classifier.joblib')
