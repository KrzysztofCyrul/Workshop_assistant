from rest_framework import serializers
from .models import EmailSettings
from clients.models import Client

class EmailSettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmailSettings
        fields = ['mail_from', 'smtp_host', 'smtp_port', 'smtp_user', 'smtp_password', 'use_tls']

    def validate_smtp_port(self, value):
        if value <= 0:
            raise serializers.ValidationError("Port musi być liczbą dodatnią")
        return value

class WorkshopEmailSerializer(serializers.Serializer):
    subject = serializers.CharField(max_length=255)
    body = serializers.CharField()
    recipients = serializers.ListField(
        child=serializers.EmailField(),
        write_only=True
    )