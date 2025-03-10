# Generated by Django 5.1.2 on 2025-01-31 16:10

import django.db.models.deletion
import uuid
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('employees', '0003_remove_employee_branch'),
        ('workshops', '0002_delete_branch'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='TemporaryCode',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('code', models.CharField(max_length=6, unique=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('expires_at', models.DateTimeField()),
                ('created_by', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='generated_codes', to=settings.AUTH_USER_MODEL)),
                ('workshop', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='temporary_codes', to='workshops.workshop')),
            ],
        ),
    ]
