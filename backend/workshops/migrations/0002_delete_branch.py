# Generated by Django 5.1.2 on 2024-11-24 10:40

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('appointments', '0006_remove_appointment_branch'),
        ('employees', '0003_remove_employee_branch'),
        ('service_orders', '0002_remove_serviceorder_branch'),
        ('workshops', '0001_initial'),
    ]

    operations = [
        migrations.DeleteModel(
            name='Branch',
        ),
    ]
