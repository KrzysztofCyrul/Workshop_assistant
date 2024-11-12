import uuid
from django.db import models
from workshops.models import Workshop

class Client(models.Model):
    SEGMENT_CHOICES = [
        ('A', 'Segment A (VIP)'),
        ('B', 'Segment B'),
        ('C', 'Segment C'),
        ('D', 'Segment D'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workshop = models.ForeignKey(
        Workshop,
        on_delete=models.CASCADE,
        related_name='clients'
    )
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    email = models.EmailField()
    phone = models.CharField(max_length=20)
    address = models.CharField(max_length=255)
    segment = models.CharField(max_length=1, choices=SEGMENT_CHOICES, null=True, blank=True)
    discount = models.DecimalField(max_digits=5, decimal_places=2, default=0.00)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.first_name} {self.last_name} - {self.workshop.name}"
