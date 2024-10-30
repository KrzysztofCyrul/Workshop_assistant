import uuid
from django.db import models
from employees.models import Employee
from workshops.models import Workshop, Branch
from clients.models import Client
from vehicles.models import Vehicle
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.utils import timezone

class Appointment(models.Model):
    STATUS_CHOICES = [
        ('scheduled', 'Zaplanowana'),
        ('completed', 'Zakończona'),
        ('canceled', 'Anulowana'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workshop = models.ForeignKey(
        Workshop,
        on_delete=models.CASCADE,
        related_name='appointments'
    )
    branch = models.ForeignKey(
        Branch,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='appointments'
    )
    client = models.ForeignKey(
        Client,
        on_delete=models.CASCADE,
        related_name='appointments'
    )
    vehicle = models.ForeignKey(
        Vehicle,
        on_delete=models.CASCADE,
        related_name='appointments'
    )
    
    assigned_mechanics = models.ManyToManyField(
        Employee,
        related_name='appointments',
        blank=True
    )
    scheduled_time = models.DateTimeField()
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='scheduled')
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    mileage = models.PositiveIntegerField(default=0)

    
    def __str__(self):
        return f"Appointment for {self.client} on {self.scheduled_time}"

    class Meta:
        ordering = ['-scheduled_time']
        
class RepairItem(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Do wykonania'),
        ('in_progress', 'W trakcie'),
        ('completed', 'Zakończone'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    appointment = models.ForeignKey(
        Appointment,
        on_delete=models.CASCADE,
        related_name='repair_items'
    )
    description = models.TextField()
    is_completed = models.BooleanField(default=False)
    completed_by = models.ForeignKey(
        Employee,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='completed_repair_items'
    )
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    order = models.PositiveIntegerField(default=0)  # Dla sortowania elementów

    def __str__(self):
        return f"{self.description} ({self.get_status_display()})"

    class Meta:
        ordering = ['order']