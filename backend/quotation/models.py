from decimal import Decimal
import uuid
from django.db import models
from django.core.exceptions import ValidationError
from clients.models import Client
from vehicles.models import Vehicle
from django.db import models
from django.db.models import Max
from datetime import datetime
from workshops.models import Workshop

class Quotation(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    client = models.ForeignKey(
        Client,
        on_delete=models.CASCADE,
        related_name='quotations'
    )
    vehicle = models.ForeignKey(
        Vehicle,
        on_delete=models.CASCADE,
        related_name='quotations'
    )
    workshop = models.ForeignKey(
        Workshop,
        on_delete=models.CASCADE,
        related_name='quotations'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    total_cost = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    quotation_number = models.CharField(max_length=20, unique=True, editable=False)  # Pole na numer wyceny

    def __str__(self):
        return f"Quotation {self.quotation_number} for {self.client}"

    def save(self, *args, **kwargs):
        if not self.quotation_number:
            today = datetime.now()
            year = today.year
            month = today.month

            last_quotation = Quotation.objects.filter(
                created_at__year=year,
                created_at__month=month
            ).aggregate(Max('quotation_number'))

            last_number = last_quotation['quotation_number__max']
            if last_number:
                last_number = int(last_number.split('/')[0])
                new_number = last_number + 1
            else:
                new_number = 1

            self.quotation_number = f"{new_number:02d}/{month:02d}/{year}"

        super().save(*args, **kwargs)

    class Meta:
        ordering = ['-created_at']

class QuotationRepairItem(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    quotation = models.ForeignKey(
        Quotation,
        on_delete=models.CASCADE,
        related_name='quotation_repair_items'
    )
    description = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    cost = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    order = models.PositiveIntegerField(default=0)

    def __str__(self):
        return f"{self.description} for {self.quotation.client}"

class QuotationPart(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    quotation = models.ForeignKey(
        Quotation,
        on_delete=models.CASCADE,
        related_name='quotation_parts'
    )
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    cost_part = models.DecimalField(max_digits=10, decimal_places=2)
    quantity = models.PositiveIntegerField(default=1)
    created_at = models.DateTimeField(auto_now_add=True) 
    updated_at = models.DateTimeField(auto_now=True)

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