# vehicles/models.py

import uuid
from django.db import models
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
    year = models.PositiveIntegerField()
    vin = models.CharField(max_length=17, unique=True) 
    license_plate = models.CharField(max_length=10)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # Relacja z wpisami serwisowymi (do zdefiniowania później)
    # service_records = models.ManyToManyField(ServiceRecord, related_name='vehicles', blank=True)

    def __str__(self):
        return f"{self.make} {self.model} ({self.license_plate})"
