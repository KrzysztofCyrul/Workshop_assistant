from django.db.models.signals import post_save
from django.dispatch import receiver
from django.utils import timezone
from appointments.models import Appointment
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
