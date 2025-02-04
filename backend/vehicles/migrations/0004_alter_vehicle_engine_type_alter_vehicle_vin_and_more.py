# Generated by Django 5.1.2 on 2025-01-24 13:50

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('vehicles', '0003_vehicle_engine_type'),
    ]

    operations = [
        migrations.AlterField(
            model_name='vehicle',
            name='engine_type',
            field=models.CharField(blank=True, max_length=50, null=True),
        ),
        migrations.AlterField(
            model_name='vehicle',
            name='vin',
            field=models.CharField(blank=True, max_length=17, null=True, unique=True),
        ),
        migrations.AlterField(
            model_name='vehicle',
            name='year',
            field=models.PositiveIntegerField(blank=True, null=True),
        ),
    ]
