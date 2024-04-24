from pathlib import Path
from django.contrib import admin
from django.urls import path
from .views import CarsView, CarDetailView, ClientsView, ClientDetailView, ServicesView, ServiceDetailView, MechanicsView, MechanicDetailView, generate_random_clients


urlpatterns = [
    path('cars/', CarsView.as_view()),
    path('cars/<int:id>/', CarDetailView.as_view()),
    path('clients/', ClientsView.as_view()),
    path('clients/<int:id>/', ClientDetailView.as_view()),
    path('services/', ServicesView.as_view()),
    path('services/<int:id>/', ServiceDetailView.as_view()),
    path('mechanics/', MechanicsView.as_view()),
    path('mechanics/<int:id>/', MechanicDetailView.as_view()),
    path('generate/', generate_random_clients),
    

]
