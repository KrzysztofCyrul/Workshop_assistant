import uuid
from datetime import timedelta
from decimal import Decimal
from django.core.management.base import BaseCommand
from django.utils.timezone import now
from clients.models import Client
from vehicles.models import Vehicle
from appointments.models import Appointment, RepairItem
import random

#  python manage.py generate_data <workshop_id> --num_clients_per_segment 5 --num_vehicles_per_client 3 --num_appointments_per_client 10

class Command(BaseCommand):
    help = 'Generates test data for appointments, clients, and vehicles'

    def add_arguments(self, parser):
        parser.add_argument('workshop_id', type=str, help='ID of the workshop')
        parser.add_argument('--num_clients_per_segment', type=int, default=3, help='Number of clients per segment to generate')
        parser.add_argument('--num_vehicles_per_client', type=int, default=2, help='Number of vehicles per client')
        parser.add_argument('--num_appointments_per_client', type=int, default=5, help='Number of appointments per client')

    def handle(self, *args, **options):
        workshop_id = options['workshop_id']
        num_clients_per_segment = options['num_clients_per_segment']
        num_vehicles_per_client = options['num_vehicles_per_client']
        num_appointments_per_client = options['num_appointments_per_client']

        self.generate_data_for_workshop(workshop_id, num_clients_per_segment, num_vehicles_per_client, num_appointments_per_client)

    def generate_data_for_workshop(self, workshop_id, num_clients_per_segment, num_vehicles_per_client, num_appointments_per_client):
        # Funkcje pomocnicze
        def random_name():
            first_names = ["Krzysztof", "Maciej", "Anna", "Piotr", "Marta"]
            last_names = ["Cyrul", "Nowak", "Kowalski", "Wiśniewski", "Zielińska"]
            return random.choice(first_names), random.choice(last_names)

        def random_vehicle():
            makes_models = [
                ("Opel", "Astra"),
                ("Audi", "A6"),
                ("BMW", "X5"),
                ("Ford", "Focus"),
                ("Toyota", "Corolla"),
                ("Volkswagen", "Golf"),
                ("Renault", "Clio"),
                ("Mazda", "6"),
            ]
            return random.choice(makes_models)

        def random_vin():
            return ''.join(random.choices('ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', k=17))

        def random_license_plate():
            return f"{random.choice('RZL')}LU{random.randint(10000, 99999)}"

        def random_engine():
            engines = [
                "1.6 Diesel",
                "2.0 Turbo Petrol",
                "1.8 Hybrid",
                "3.0 V6 Petrol",
                "2.2 Diesel",
                "1.4 Petrol",
                "Electric"
            ]
            return random.choice(engines)

        def repair_items_examples():
            return [
                "Wymienić tarcze hamulcowe",
                "Naprawić układ wydechowy",
                "Wymiana oleju silnikowego i filtra",
                "Wymiana świec zapłonowych",
                "Sprawdzenie układu klimatyzacji",
                "Wymiana łożysk koła",
                "Naprawa sprzęgła",
                "Regeneracja alternatora",
                "Sprawdzenie układu kierowniczego",
                "Wymiana rozrządu",
                "Diagnostyka komputerowa",
                "Naprawa czujnika ABS",
                "Uszczelnienie silnika",
                "Wymiana pompy paliwa",
                "Sprawdzenie akumulatora",
                "Wymiana filtra powietrza",
                "Naprawa zawieszenia",
                "Ustawienie geometrii kół",
                "Czyszczenie układu dolotowego",
                "Wymiana żarówek reflektorów",
            ]

        # Funkcja do generowania klientów dla poszczególnych segmentów
        def generate_clients_for_segment(segment, num_clients):
            clients = []
            for _ in range(num_clients):
                first_name, last_name = random_name()
                client = Client.objects.create(
                    id=uuid.uuid4(),
                    workshop_id=workshop_id,
                    first_name=first_name,
                    last_name=last_name,
                    email=f"{first_name.lower()}.{last_name.lower()}_{segment}@example.com",
                    phone=f"{random.randint(500000000, 999999999)}",
                    address=f"Malawa {random.randint(1, 999)}",
                    created_at=now() - timedelta(days=random.randint(0, 365)),
                    updated_at=now()
                )
                clients.append(client)

                # Tworzenie pojazdów dla klienta
                for _ in range(num_vehicles_per_client):
                    make, model = random_vehicle()

                    # Ustawianie cech pojazdu w zależności od segmentu
                    if segment == 'A':
                        vehicle_year = now().year - random.randint(0, 5)
                        vehicle_mileage = random.randint(0, 50000)
                    elif segment == 'B':
                        vehicle_year = now().year - random.randint(5, 10)
                        vehicle_mileage = random.randint(50001, 100000)
                    elif segment == 'C':
                        vehicle_year = now().year - random.randint(10, 15)
                        vehicle_mileage = random.randint(100001, 150000)
                    else:  # Segment D
                        vehicle_year = now().year - random.randint(15, 25)
                        vehicle_mileage = random.randint(150001, 300000)

                    Vehicle.objects.create(
                        id=uuid.uuid4(),
                        client=client,
                        make=make,
                        model=model,
                        year=vehicle_year,
                        vin=random_vin(),
                        license_plate=random_license_plate(),
                        engine_type=random_engine(),
                        mileage=vehicle_mileage,
                        created_at=now(),
                        updated_at=now()
                    )

                # Generowanie wizyt dla klienta
                total_appointments = num_appointments_per_client
                if segment == 'A':
                    recency_days = random.randint(0, 30)
                    frequency = random.randint(11, 20)
                    monetary_value = random.uniform(5001, 10000)
                    avg_cost = monetary_value / frequency
                    canceled_count = 0
                    cancellation_rate = 0
                elif segment == 'B':
                    recency_days = random.randint(31, 90)
                    frequency = random.randint(6, 10)
                    monetary_value = random.uniform(2001, 5000)
                    avg_cost = monetary_value / frequency
                    canceled_count = random.randint(0, 1)
                    cancellation_rate = canceled_count / (frequency + canceled_count)
                elif segment == 'C':
                    recency_days = random.randint(91, 180)
                    frequency = random.randint(1, 5)
                    monetary_value = random.uniform(1001, 2000)
                    avg_cost = monetary_value / frequency
                    canceled_count = random.randint(0, 2)
                    cancellation_rate = canceled_count / (frequency + canceled_count)
                else:  # Segment D
                    recency_days = random.randint(181, 365)
                    frequency = random.randint(0, 5)
                    monetary_value = random.uniform(0, 1000)
                    avg_cost = monetary_value / frequency if frequency > 0 else 0
                    canceled_count = random.randint(2, 5)
                    cancellation_rate = canceled_count / (frequency + canceled_count) if (frequency + canceled_count) > 0 else 0

                total_visits = frequency + canceled_count
                last_visit_date = now() - timedelta(days=recency_days)
                first_visit_date = last_visit_date - timedelta(days=random.randint(30, 180))

                for _ in range(total_visits):
                    is_canceled = random.random() < cancellation_rate
                    status = 'canceled' if is_canceled else 'completed'
                    scheduled_time = first_visit_date + timedelta(days=random.randint(0, (last_visit_date - first_visit_date).days))
                    vehicle = random.choice(client.vehicles.all())
                    appointment = Appointment.objects.create(
                        id=uuid.uuid4(),
                        workshop_id=workshop_id,
                        client=client,
                        vehicle=vehicle,
                        scheduled_time=scheduled_time,
                        status=status,
                        mileage=vehicle.mileage + random.randint(1000, 5000),
                        notes="Losowe uwagi dotyczące wizyty.",
                        total_cost=Decimal(f"{avg_cost:.2f}") if status == 'completed' else Decimal('0.00'),
                        created_at=scheduled_time - timedelta(days=random.randint(1, 5)),
                        updated_at=scheduled_time
                    )

                    # Tworzenie zadań do naprawy dla zakończonych wizyt
                    if status == 'completed':
                        repair_examples = repair_items_examples()
                        for i in range(random.randint(2, 5)):
                            RepairItem.objects.create(
                                id=uuid.uuid4(),
                                appointment=appointment,
                                description=random.choice(repair_examples),
                                status="completed",
                                cost=Decimal(f"{random.randint(50, 500)}.00"),
                                created_at=scheduled_time,
                                updated_at=scheduled_time + timedelta(hours=random.randint(1, 5)),
                                order=i
                            )

            return clients

        # Generowanie danych dla każdego segmentu
        all_clients = []
        segments = ['A', 'B', 'C', 'D']
        for segment in segments:
            clients = generate_clients_for_segment(segment, num_clients_per_segment)
            all_clients.extend(clients)

        self.stdout.write(self.style.SUCCESS(
            f"Utworzono {len(all_clients)} klientów, ich pojazdy i wizyty dla warsztatu {workshop_id}.")
        )
