from appointments.models import Appointment, RepairItem

# Pobierz istniejący appointment
appointment = Appointment.objects.first()

# Dodaj nowy RepairItem z przykładowym opisem
repair_item = RepairItem.objects.create(
    appointment=appointment,
    description="Wymiana oleju silnikowego"
)

# Sprawdź, czy estimated_duration zostało ustawione
print(f"Szacowany czas naprawy: {repair_item.estimated_duration}")
