from pathlib import Path
from django.contrib import admin
from django.urls import path
from . import views

urlpatterns = [
    path('cars/', views.CarsView.as_view()),
    path('cars/<int:id>/', views.CarDetailView.as_view()),
    path('clients/', views.ClientsView.as_view()),
    path('clients/<int:id>/', views.ClientDetailView.as_view()),
    path('services/', views.VisitView.as_view()),
    path('services/<str:id>', views.VisitDetailView.as_view()),
    path('mechanics/', views.MechanicsView.as_view()),
    path('mechanics/<int:id>/', views.MechanicDetailView.as_view()),
    path('visit/', views.ClientVisitView.as_view()),
    path('visit/<str:id>', views.ClientVisitDetailView.as_view()),
    path('generate/', views.generate_random_clients),
]
