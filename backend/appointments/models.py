from decimal import Decimal
import uuid
from django.db import models
from django.core.exceptions import ValidationError
from employees.models import Employee
from workshops.models import Workshop
from clients.models import Client
from vehicles.models import Vehicle

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
    recommendations = models.TextField(null=True, blank=True)
    estimated_duration = models.DurationField(null=True, blank=True)
    total_cost = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)

    def __str__(self):
        return f"Appointment for {self.client} on {self.scheduled_time}"

    def calculate_total_cost(self):
        repair_items_cost = sum(item.cost for item in self.repair_items.all())
        parts_cost = sum(part.total_cost for part in self.parts.all())

        total_cost = repair_items_cost + parts_cost

        # Apply client's discount
        discount_rate = Decimal(self.client.discount) / Decimal(100)
        discount_amount = total_cost * discount_rate
        total_cost_after_discount = total_cost - discount_amount

        self.total_cost = total_cost_after_discount
        self.save()

    class Meta:
        ordering = ['-scheduled_time']

class RepairItem(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Do wykonania'),
        ('in_progress', 'W trakcie'),
        ('completed', 'Zakończone'),
        ('canceled', 'Anulowane'),
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
    estimated_duration = models.DurationField(null=True, blank=True)
    actual_duration = models.DurationField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    cost = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    order = models.PositiveIntegerField(default=0)

    def __str__(self):
        return f"{self.description} ({self.get_status_display()}), assigned to {self.appointment.client}"

    class Meta:
        ordering = ['order']

class Part(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    appointment = models.ForeignKey(
        Appointment,
        on_delete=models.CASCADE,
        related_name='parts'
    )
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    cost_part = models.DecimalField(max_digits=10, decimal_places=2)
    cost_service = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    quantity = models.PositiveIntegerField(default=1)


    def clean(self):
        if self.cost_part < 0:
            raise ValidationError("Koszt nie może być ujemny.")
        if self.quantity < 1:
            raise ValidationError("Ilość musi być większa lub równa 1.")

    @property
    def total_cost(self):
        return self.cost_part * self.quantity

    def __str__(self):
        return f"{self.name} x{self.quantity} ({self.cost_part} zł)"
