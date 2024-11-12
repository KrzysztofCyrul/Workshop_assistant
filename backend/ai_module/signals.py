import os
from datetime import timedelta
from django.db.models.signals import post_save, pre_save
from django.dispatch import receiver
from appointments.models import RepairItem
from django.conf import settings
import openai

def get_estimated_duration(vehicle_info, repair_description):
    openai.api_key = settings.API_KEY

    messages = [
        {
            "role": "system",
            "content": (
                "Jesteś doświadczonym mechanikiem samochodowym. "
                "Na podstawie informacji o pojeździe i opisu naprawy, "
                "oszacuj czas trwania naprawy w formacie HH:MM.\n"
                "Jeśli czas to jedna godzina i 30 minut, odpowiedz: 01:30.\n"
                "Nie dodawaj żadnych dodatkowych informacji, tylko sam czas w formacie HH:MM."
            )
        },
        {
            "role": "user",
            "content": (
                f"Informacje o pojeździe:\n{vehicle_info}\n\n"
                f"Opis naprawy:\n{repair_description}\n\n"
                "Proszę podać tylko szacowany czas trwania w formacie HH:MM."
            )
        }
    ]

    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=messages,
            max_tokens=10,
            temperature=0
        )

        estimated_duration = response.choices[0].message['content'].strip()
        print(f"Odpowiedź z API: {estimated_duration}")  # Dodaj ten print
        return estimated_duration
    except Exception as e:
        # Obsłuż błędy API
        print(f"Błąd podczas komunikacji z API OpenAI: {e}")
        return None

# Function to track if the repair description has changed before saving.
@receiver(pre_save, sender=RepairItem)
def track_description_change(sender, instance, **kwargs):
    """
    """
    if instance.pk:  # Check only for existing records
        try:
            previous_instance = sender.objects.get(pk=instance.pk)
            instance._previous_description = previous_instance.description
        except sender.DoesNotExist:
            instance._previous_description = None


@receiver(post_save, sender=RepairItem)
def estimate_repair_duration(sender, instance, created, **kwargs):
    """
    Function triggered after saving a RepairItem record.
    It estimates the repair duration if the description has changed
    or if the estimated duration is not already set.
    """
    print("Signal estimate_repair_duration triggered")

    # Check if the description has changed or if estimated_duration is not set
    description_changed = hasattr(instance, '_previous_description') and (
        instance.description != instance._previous_description
    )

    if not instance.estimated_duration or description_changed:
        print("Description changed or estimated duration is not set. Estimating duration.")
        vehicle = instance.appointment.vehicle
        engine_info = f"Engine Type: {vehicle.engine_type}, " if vehicle.engine_type else ""
        vehicle_info = (
            f"Make: {vehicle.make}, Model: {vehicle.model}, Year: {vehicle.year}, "
            f"{engine_info}Mileage: {vehicle.mileage} km"
        )
        repair_description = instance.description

        print(f"Vehicle Info: {vehicle_info}")
        print(f"Repair Description: {repair_description}")

        # Call the function to get the estimated duration
        estimated_duration_str = get_estimated_duration(vehicle_info, repair_description)

        print(f"Received estimated duration: {estimated_duration_str}")

        if estimated_duration_str:
            # Parse time in the format HH:MM
            try:
                hours, minutes = map(int, estimated_duration_str.strip().split(':'))
                estimated_duration = timedelta(hours=hours, minutes=minutes)
                instance.estimated_duration = estimated_duration
                instance.save()
            except ValueError:
                # Handle parsing error
                print(f"Error parsing duration: {estimated_duration_str}")
        else:
            print("Failed to get an estimated duration.")
            
def get_appointment_recommendations(appointment_description, repair_items):
    openai.api_key = settings.API_KEY

    # Przygotuj treść wiadomości
    repair_items_list = '\n'.join([f"- {item.description}" for item in repair_items])
    messages = [
        {
            "role": "system",
            "content": (
                "Jesteś doświadczonym doradcą serwisowym w warsztacie samochodowym. "
                "Na podstawie opisu wizyty i listy prac do wykonania, "
                "proszę zasugerować optymalną kolejność wykonywania napraw oraz udzielić cennych wskazówek. "
                "Odpowiedź powinna być w języku polskim."
            )
        },
        {
            "role": "user",
            "content": (
                f"Opis wizyty:\n{appointment_description}\n\n"
                f"Lista prac do wykonania:\n{repair_items_list}\n\n"
                "Proszę podać sugestie dotyczące kolejności wykonywania napraw oraz cenne wskazówki."
            )
        }
    ]

    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=messages,
            max_tokens=500,
            temperature=0.7
        )

        recommendations = response.choices[0].message['content'].strip()
        return recommendations
    except Exception as e:
        print(f"Błąd podczas komunikacji z API OpenAI: {e}")
        return None
    
@receiver(post_save, sender=RepairItem)
def update_appointment_recommendations(sender, instance, created, **kwargs):
    if created:
        appointment = instance.appointment
        repair_items = appointment.repair_items.all()
        appointment_description = appointment.notes or "Brak opisu wizyty."

        recommendations = get_appointment_recommendations(appointment_description, repair_items)

        if recommendations:
            appointment.recommendations = recommendations
            appointment.save()
            print("Zaktualizowano recommendations dla appointment.")
        else:
            print("Nie udało się uzyskać recommendations.")
