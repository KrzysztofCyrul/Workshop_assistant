# Generated by Django 5.0.4 on 2024-06-02 23:14

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('visit', '0011_alter_visit_status'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='visit',
            name='is_active',
        ),
    ]