from datetime import timedelta
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.utils import timezone
from appointments.models import Appointment, RepairItem
from ai_module.ml_model import predict_segment
from service_records.models import ServiceRecord
from ai_module.utils import SEGMENT_DISCOUNTS

@receiver(post_save, sender=Appointment)
def create_service_record(sender, instance, created, **kwargs):
    if not created and instance.status == 'completed':
        if not ServiceRecord.objects.filter(appointment=instance).exists():
            repair_items = instance.repair_items.all()
            repair_descriptions = [item.description for item in repair_items]
            descriptions = []
            if instance.notes:
                descriptions.append(instance.notes)
            descriptions.extend(repair_descriptions)
            full_description = '\n'.join(descriptions)
            ServiceRecord.objects.create(
                vehicle=instance.vehicle,
                appointment=instance,
                date=timezone.now().date(),
                description=full_description,
                mileage=instance.mileage,
            )
            # Zaktualizuj przebieg pojazdu
            instance.vehicle.mileage = instance.mileage
            instance.vehicle.save()

                
@receiver(post_save, sender=RepairItem)
def update_appointment_status(sender, instance, **kwargs):
    appointment = instance.appointment
    repair_items = appointment.repair_items.all()
    if repair_items.exists() and all(item.status == 'completed' for item in repair_items):
        appointment.status = 'completed'
        appointment.save()
        
@receiver([post_save, post_delete], sender=RepairItem)
def update_appointment_total_cost(sender, instance, **kwargs):
    appointment = instance.appointment
    appointment.calculate_total_cost()
    
@receiver(post_save, sender=RepairItem)
def update_total_time(sender, instance, **kwargs):
    appointment = instance.appointment
    repair_items = appointment.repair_items.all()
    total_time = sum(item.estimated_duration.total_seconds() for item in repair_items)
    appointment.estimated_duration = timedelta(seconds=total_time)
    appointment.save()

@receiver(post_save, sender=Appointment)
def update_client_segment(sender, instance, **kwargs):
    if instance.status == 'completed':
        client = instance.client
        previous_segment = client.segment
        predicted_segment = predict_segment(client)
        client.segment = predicted_segment
        client.discount = SEGMENT_DISCOUNTS.get(predicted_segment, 0.00)
        client.save()
        
        if predicted_segment != previous_segment:
            print(f"Segment klienta {client} zmieniony z {previous_segment} na {predicted_segment}")
