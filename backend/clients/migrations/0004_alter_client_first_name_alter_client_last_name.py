# Generated by Django 5.1.2 on 2025-03-10 14:53

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('clients', '0003_alter_client_address_alter_client_email'),
    ]

    operations = [
        migrations.AlterField(
            model_name='client',
            name='first_name',
            field=models.CharField(blank=True, max_length=50, null=True),
        ),
        migrations.AlterField(
            model_name='client',
            name='last_name',
            field=models.CharField(blank=True, max_length=50, null=True),
        ),
    ]
