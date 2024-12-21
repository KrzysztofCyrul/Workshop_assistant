from django.core.mail import EmailMessage
from django.core.mail.backends.smtp import EmailBackend
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.generics import RetrieveUpdateAPIView
from .models import EmailSettings, Workshop
from clients.models import Client
from .serializers import WorkshopEmailSerializer, EmailSettingsSerializer
from rest_framework import serializers
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import ValidationError
from accounts.permissions import IsWorkshopOwner, IsAdmin
import logging

logger = logging.getLogger(__name__)


class EmailSettingsView(RetrieveUpdateAPIView):
    serializer_class = EmailSettingsSerializer
    permission_classes = [IsAuthenticated, IsWorkshopOwner | IsAdmin]

    def get_object(self):
        workshop_id = self.kwargs.get('workshop_pk')

        try:
            workshop = Workshop.objects.get(id=workshop_id)
        except Workshop.DoesNotExist:
            raise ValidationError({"error": "Workshop not found."})

        # Utwórz domyślne ustawienia e-mail, jeśli ich brak
        email_settings, created = EmailSettings.objects.get_or_create(
            workshop=workshop,
            defaults={
                'mail_from': '',
                'smtp_host': '',
                'smtp_port': 587,  # Domyślny port SMTP
                'smtp_user': '',
                'smtp_password': '',
                'use_tls': True
            }
        )
        return email_settings