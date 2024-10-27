import uuid
from django.db import models
from service_orders.models import ServiceOrder
from employees.models import Employee

class ServiceTask(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Do wykonania'),
        ('in_progress', 'W trakcie'),
        ('completed', 'Zakończone'),
        ('canceled', 'Anulowane'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    service_order = models.ForeignKey(
        ServiceOrder,
        on_delete=models.CASCADE,
        related_name='tasks'
    )
    description = models.TextField()
    assigned_to = models.ForeignKey(
        Employee,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='tasks'
    )
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    estimated_time = models.DecimalField(max_digits=5, decimal_places=2)  # W godzinach
    actual_time = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)  # W godzinach
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Zadanie {self.id} dla zlecenia {self.service_order.id}"

    class Meta:
        ordering = ['-created_at']
