import uuid
from django.db import models
from vehicles.models import Vehicle
from appointments.models import Appointment
import uuid
from django.db import models
from vehicles.models import Vehicle

class ServiceRecord(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    vehicle = models.ForeignKey(
        Vehicle,
        on_delete=models.CASCADE,
        related_name='service_records'
    )
    appointment = models.OneToOneField(
        'appointments.Appointment',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='service_record'
    )
    date = models.DateField()
    description = models.TextField()
    mileage = models.PositiveIntegerField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Service on {self.date} for {self.vehicle}"
