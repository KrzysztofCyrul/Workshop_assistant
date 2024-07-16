from pathlib import Path
from django.contrib import admin
from django.urls import path
from . import views

urlpatterns = [
    path('cars/', views.CarsView.as_view()),
    path('cars/<int:id>/', views.CarDetailView.as_view()),
    
    path('clients/', views.ClientsView.as_view()),
    path('clients/<int:id>/', views.ClientDetailView.as_view()),
    
    path('companies/', views.CompaniesView.as_view()),
    path('companies/<int:id>/', views.CompanyDetailView.as_view()),
    
    path('mechanics/', views.MechanicsView.as_view()),
    path('mechanics/<int:id>/', views.MechanicDetailView.as_view()),
    
    path('visits/', views.VisitView.as_view()),
    path('visit/<str:pk>', views.VisitDetailView.as_view()),
    path('visit/update-striked/<str:pk>', views.UpdateStrikedLines.as_view(), name='update-striked-lines'),
    
    path('parts/', views.PartsView.as_view()),
    path('parts/<int:id>/', views.PartDetailView.as_view()),
    
    path('services/', views.ServiceView.as_view()),
    path('services/<int:id>/', views.ServiceDetailView.as_view()),
    
    path('estimates/', views.EstimateView.as_view()),
    path('estimates/<str:pk>/', views.EstimateDetailView.as_view()),

    path('generate/', views.generate_random_clients),
]
