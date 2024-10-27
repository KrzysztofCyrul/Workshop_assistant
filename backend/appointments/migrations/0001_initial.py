# Generated by Django 5.1.2 on 2024-10-27 18:20

import django.db.models.deletion
import uuid
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('clients', '0001_initial'),
        ('vehicles', '0002_vehicle_mileage'),
        ('workshops', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Appointment',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('scheduled_time', models.DateTimeField()),
                ('status', models.CharField(choices=[('scheduled', 'Zaplanowana'), ('completed', 'Zakończona'), ('canceled', 'Anulowana')], default='scheduled', max_length=10)),
                ('notes', models.TextField(blank=True, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('mileage', models.PositiveIntegerField(default=0)),
                ('branch', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='appointments', to='workshops.branch')),
                ('client', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='appointments', to='clients.client')),
                ('vehicle', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='appointments', to='vehicles.vehicle')),
                ('workshop', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='appointments', to='workshops.workshop')),
            ],
            options={
                'ordering': ['-scheduled_time'],
            },
        ),
    ]