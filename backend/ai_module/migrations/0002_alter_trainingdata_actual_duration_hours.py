from django.db import migrations

class Migration(migrations.Migration):

    dependencies = [
        ('ai_module', '0001_initial'),
    ]

    operations = [
        migrations.RunSQL(
            """
            ALTER TABLE ai_module_trainingdata
            ALTER COLUMN actual_duration_hours TYPE interval
            USING actual_duration_hours * interval '1 hour';
            """
        ),
    ]
