# Generated by Django 5.1.2 on 2024-12-21 12:16

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('emailer', '0003_emailsettings_mail_from'),
    ]

    operations = [
        migrations.AlterField(
            model_name='emailsettings',
            name='mail_from',
            field=models.CharField(blank=True, default='', max_length=255),
        ),
    ]