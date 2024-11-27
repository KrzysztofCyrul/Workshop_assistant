import uuid
from datetime import timedelta
from decimal import Decimal
from django.core.management.base import BaseCommand
from django.utils.timezone import now
from clients.models import Client
from vehicles.models import Vehicle
from appointments.models import Appointment, RepairItem
import random

#  python manage.py generate_data <workshop_id> --num_clients 5 --num_vehicles_per_client 3 --num_appointments 10

class Command(BaseCommand):
    help = 'Generates test data for appointments, clients, and vehicles'

    def add_arguments(self, parser):
        parser.add_argument('workshop_id', type=str, help='ID of the workshop')
        parser.add_argument('--num_clients', type=int, default=3, help='Number of clients to generate')
        parser.add_argument('--num_vehicles_per_client', type=int, default=2, help='Number of vehicles per client')
        parser.add_argument('--num_appointments', type=int, default=5, help='Number of appointments to generate')

    def handle(self, *args, **options):
        workshop_id = options['workshop_id']
        num_clients = options['num_clients']
        num_vehicles_per_client = options['num_vehicles_per_client']
        num_appointments = options['num_appointments']

        self.generate_data_for_workshop(workshop_id, num_clients, num_vehicles_per_client, num_appointments)

    def generate_data_for_workshop(self, workshop_id, num_clients, num_vehicles_per_client, num_appointments):
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

        # Generowanie klientów i pojazdów
        clients = []
        for _ in range(num_clients):
            first_name, last_name = random_name()
            client = Client.objects.create(
                id=uuid.uuid4(),
                workshop_id=workshop_id,
                first_name=first_name,
                last_name=last_name,
                email=f"{first_name.lower()}.{last_name.lower()}@example.com",
                phone=f"{random.randint(500000000, 999999999)}",
                address=f"Malawa {random.randint(1, 999)}",
                created_at=now(),
                updated_at=now()
            )
            clients.append(client)

            # Tworzenie pojazdów dla klienta
            for _ in range(num_vehicles_per_client):
                make, model = random_vehicle()
                Vehicle.objects.create(
                    id=uuid.uuid4(),
                    client=client,
                    make=make,
                    model=model,
                    year=random.randint(1995, 2022),
                    vin=random_vin(),
                    license_plate=random_license_plate(),
                    engine_type=random_engine(),
                    created_at=now(),
                    updated_at=now()
                )

        # Generowanie wizyt
        for _ in range(num_appointments):
            client = random.choice(clients)
            vehicle = random.choice(client.vehicles.all())
            appointment = Appointment.objects.create(
                id=uuid.uuid4(),
                workshop_id=workshop_id,
                client=client,
                vehicle=vehicle,
                scheduled_time=now() + timedelta(days=random.randint(1, 30)),
                status=random.choice(['scheduled', 'completed']),
                mileage=random.randint(50000, 200000),
                notes="Losowe uwagi dotyczące wizyty.",
                created_at=now(),
                updated_at=now()
            )

            # Tworzenie zadań do naprawy
            repair_examples = repair_items_examples()
            for i in range(random.randint(2, 5)):
                RepairItem.objects.create(
                    id=uuid.uuid4(),
                    appointment=appointment,
                    description=random.choice(repair_examples),
                    status=random.choice(["pending", "in_progress", "completed"]),
                    cost=Decimal(f"{random.randint(50, 500)}.00"),
                    created_at=now(),
                    updated_at=now(),
                    order=i
                )

        self.stdout.write(self.style.SUCCESS(
            f"Utworzono {num_clients} klientów, ich pojazdy i {num_appointments} wizyt dla warsztatu {workshop_id}.")
        )
