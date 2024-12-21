from django.db import models
from workshops.models import Workshop

class EmailSettings(models.Model):
    workshop = models.OneToOneField(
        Workshop,
        on_delete=models.CASCADE,
        related_name='email_settings'
    )
    mail_from = models.CharField(max_length=255, blank=True, default="")
    smtp_host = models.CharField(max_length=255, blank=True, default="")
    smtp_port = models.IntegerField(default=587)  # Domyślny port SMTP
    smtp_user = models.EmailField(blank=True, default="")
    smtp_password = models.CharField(max_length=255, blank=True, default="")
    use_tls = models.BooleanField(default=True)

    def __str__(self):
        return f"Email settings for {self.workshop.name}"
