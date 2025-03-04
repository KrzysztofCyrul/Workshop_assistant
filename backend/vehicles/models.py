import uuid
from django.db import models
from django.core.exceptions import ValidationError
from clients.models import Client

class Vehicle(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    client = models.ForeignKey(
        Client,
        on_delete=models.CASCADE,
        related_name='vehicles'
    )
    
    make = models.CharField(max_length=50)
    model = models.CharField(max_length=50)
    year = models.PositiveIntegerField(blank=True, null=True)
    engine_type = models.CharField(max_length=50, blank=True, null=True)
    vin = models.CharField(max_length=17, blank=True, null=True) 
    license_plate = models.CharField(max_length=10)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    mileage = models.PositiveIntegerField(default=0)

    
    # Relacja z wpisami serwisowymi (do zdefiniowania później)
    # service_records = models.ManyToManyField(ServiceRecord, related_name='vehicles', blank=True)
    class Meta:
        constraints = [
            models.UniqueConstraint(fields=['license_plate', 'client'], name='unique_license_plate_per_client')
        ]

    def clean(self):
        # Ensure the license plate is unique within the workshop
        if Vehicle.objects.filter(license_plate=self.license_plate, client__workshop=self.client.workshop).exclude(id=self.id).exists():
            raise ValidationError(f"Vehicle with license plate {self.license_plate} already exists in this workshop.")
     
    def save(self, *args, **kwargs):
        # Convert license_plate to uppercase before saving
        self.license_plate = self.license_plate.upper()
        super().save(*args, **kwargs) 
        
    def __str__(self):
        return f"{self.make} {self.model} ({self.license_plate})"