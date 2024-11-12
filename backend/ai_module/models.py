from django.db import models

class TrainingData(models.Model):
    description = models.TextField()
    make = models.CharField(max_length=50)
    model = models.CharField(max_length=50)
    year = models.PositiveIntegerField()
    engine = models.CharField(max_length=50)
    actual_duration_hours = models.FloatField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.description} - {self.actual_duration_hours}h"
