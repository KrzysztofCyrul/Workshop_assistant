import uuid
import random
from faker import Faker
from workshops.models import Workshop
from clients.models import Client

fake = Faker()

SEGMENT_CHOICES = ['A', 'B', 'C', 'D']

def generate_clients(workshop_id, count=10):
    try:
        # Konwersja workshop_id na UUID
        workshop_uuid = uuid.UUID(workshop_id)
        workshop = Workshop.objects.get(id=workshop_uuid)
    except ValueError:
        print("Invalid UUID format for workshop_id.")
        return
    except Workshop.DoesNotExist:
        print(f"Workshop with id {workshop_id} does not exist.")
        return

    clients = []
    for _ in range(count):
        first_name = fake.first_name()
        last_name = fake.last_name()
        email = fake.email()
        phone = fake.phone_number()
        address = fake.address()
        segment = random.choice(SEGMENT_CHOICES)
        discount = round(random.uniform(0, 20), 2)

        client = Client(
            id=uuid.uuid4(),
            workshop=workshop,
            first_name=first_name,
            last_name=last_name,
            email=email,
            phone=phone,
            address=address,
            segment=segment,
            discount=discount
        )

        clients.append(client)

    # Bulk create for lepszej wydajności
    Client.objects.bulk_create(clients)
    print(f"Successfully generated {count} clients for workshop: {workshop.name}")

# Przykład użycia:
# generate_clients('3fa85f64-5717-4562-b3fc-2c963f66afa6', count=20)
