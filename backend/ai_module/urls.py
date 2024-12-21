from django.urls import path
from .views import generate_email_content

urlpatterns = [
    path('generate-email/', generate_email_content, name='generate_email_content'),
]
