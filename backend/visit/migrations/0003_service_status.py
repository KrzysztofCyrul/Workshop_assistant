# Generated by Django 5.0.4 on 2024-05-05 14:29

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('visit', '0002_company_alter_client_phone_alter_service_cars_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='service',
            name='status',
            field=models.CharField(choices=[('pending', 'Oczekujące'), ('in_progress', 'W trakcie'), ('done', 'Zakończone')], default='pending', max_length=50),
        ),
    ]