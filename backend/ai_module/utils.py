import pandas as pd
from django.utils import timezone
from django.db.models import Sum, Count, Max
from clients.models import Client

SEGMENT_DISCOUNTS = {
    'A': 20.00,  # 20% rabatu
    'B': 10.00,  # 10% rabatu
    'C': 5.00,   # 5% rabatu
    'D': 0.00,   # Brak rabatu
}

def calculate_rfm():
    clients = Client.objects.all()
    data = []
    today = timezone.now().date()

    for client in clients:
        appointments = client.appointments.filter(status='completed')

        if appointments.exists():
            frequency = appointments.count()
            monetary_value = appointments.aggregate(total_spent=Sum('total_cost'))['total_spent'] or 0
            last_appointment_date = appointments.aggregate(last_date=Max('scheduled_time'))['last_date'].date()
            recency = (today - last_appointment_date).days
        else:
            frequency = 0
            monetary_value = 0
            recency = None  # Możemy przypisać wysoką wartość później

        data.append({
            'client_id': client.id,
            'recency': recency,
            'frequency': frequency,
            'monetary_value': monetary_value,
        })

    df = pd.DataFrame(data)
    return df

def assign_rfm_scores(df):
    # Zastąp wartości None w recency wysoką liczbą
    max_recency = df['recency'].max() or 0
    df['recency'].fillna(max_recency + 10, inplace=True)

    # Przypisz punkty RFM
    df['R_score'] = pd.qcut(df['recency'], 4, labels=[4, 3, 2, 1]).astype(int)
    df['F_score'] = pd.qcut(df['frequency'].rank(method='first'), 4, labels=[1, 2, 3, 4]).astype(int)
    df['M_score'] = pd.qcut(df['monetary_value'], 4, labels=[1, 2, 3, 4]).astype(int)

    # Oblicz łączny wynik RFM
    df['RFM_score'] = df['R_score'] + df['F_score'] + df['M_score']

    return df

def assign_segments(df):
    def segment_rfm(row):
        if row['RFM_score'] >= 10:
            return 'A'
        elif row['RFM_score'] >= 7:
            return 'B'
        elif row['RFM_score'] >= 4:
            return 'C'
        else:
            return 'D'

    df['segment'] = df.apply(segment_rfm, axis=1)
    return df

def update_client_segments(df):
    for index, row in df.iterrows():
        client = Client.objects.get(id=row['client_id'])
        client.segment = row['segment']
        client.discount = SEGMENT_DISCOUNTS.get(row['segment'], 0.00)
        client.save()

def run_rfm_segmentation():
    df = calculate_rfm()
    df = assign_rfm_scores(df)
    df = assign_segments(df)
    update_client_segments(df)
