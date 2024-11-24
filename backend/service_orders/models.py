import uuid
from django.db import models
from workshops.models import Workshop
from appointments.models import Appointment
from clients.models import Client
from vehicles.models import Vehicle
from employees.models import Employee

class ServiceOrder(models.Model):
    STATUS_CHOICES = [
        ('in_progress', 'W trakcie'),
        ('completed', 'Zakończone'),
        ('canceled', 'Anulowane'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    appointment = models.ForeignKey(
        'appointments.Appointment',  # Używamy stringowego odniesienia
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='service_orders'
    )
    workshop = models.ForeignKey(
        Workshop,
        on_delete=models.CASCADE,
        related_name='service_orders'
    )
    client = models.ForeignKey(
        Client,
        on_delete=models.CASCADE,
        related_name='service_orders'
    )
    vehicle = models.ForeignKey(
        Vehicle,
        on_delete=models.CASCADE,
        related_name='service_orders'
    )
    assigned_to = models.ForeignKey(
        Employee,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='assigned_orders'
    )
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='in_progress')
    total_cost = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # Relacje zostaną dodane później (tasks, invoices)

    def __str__(self):
        return f"Zlecenie {self.id} dla pojazdu {self.vehicle}"

    class Meta:
        ordering = ['-created_at']
