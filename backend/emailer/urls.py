from django.urls import path
from .views import EmailSettingsView

urlpatterns = [
    path ('workshops/<uuid:workshop_pk>/email-settings/', EmailSettingsView.as_view(), name='email-settings'),
]