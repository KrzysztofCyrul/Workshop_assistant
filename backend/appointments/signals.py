from datetime import timedelta
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.utils import timezone
from appointments.models import Appointment, RepairItem
from service_records.models import ServiceRecord

@receiver(post_save, sender=Appointment)
def create_service_record(sender, instance, created, **kwargs):
    if not created and instance.status == 'completed':
        if not hasattr(instance, 'service_record'):
            ServiceRecord.objects.create(
                vehicle=instance.vehicle,
                appointment=instance,
                date=timezone.now().date(),
                description=instance.notes or '',
                mileage=instance.mileage,
            )
            # Update vehicle mileage
            instance.vehicle.mileage = instance.mileage
            instance.vehicle.save()
                
@receiver(post_save, sender=RepairItem)
def update_appointment_status(sender, instance, **kwargs):
    appointment = instance.appointment
    repair_items = appointment.repair_items.all()
    if repair_items.exists() and all(item.status == 'completed' for item in repair_items):
        appointment.status = 'completed'
        appointment.save()
