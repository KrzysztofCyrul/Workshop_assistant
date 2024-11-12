# ai_module/urls.py

from django.urls import path
from . import views

urlpatterns = [
    path('predict_repair_time/', views.predict_repair_time, name='predict_repair_time'),
]
