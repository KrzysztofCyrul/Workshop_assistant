# Generated by Django 5.1.2 on 2025-03-10 14:53

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('workshops', '0002_delete_branch'),
    ]

    operations = [
        migrations.AddField(
            model_name='workshop',
            name='email',
            field=models.EmailField(blank=True, max_length=254, null=True),
        ),
        migrations.AddField(
            model_name='workshop',
            name='nip_number',
            field=models.CharField(blank=True, max_length=13, null=True),
        ),
        migrations.AddField(
            model_name='workshop',
            name='phone',
            field=models.CharField(blank=True, max_length=20, null=True),
        ),
        migrations.AddField(
            model_name='workshop',
            name='post_code',
            field=models.CharField(blank=True, max_length=10, null=True),
        ),
        migrations.AlterField(
            model_name='workshop',
            name='address',
            field=models.CharField(blank=True, max_length=255, null=True),
        ),
    ]
