# Generated by Django 5.0.4 on 2024-05-05 14:38

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('visit', '0003_service_status'),
    ]

    operations = [
        migrations.RenameModel(
            old_name='Service',
            new_name='Visit',
        ),
    ]