# Generated by Django 5.1.2 on 2024-11-24 10:40

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('employees', '0002_employee_status'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='employee',
            name='branch',
        ),
    ]
