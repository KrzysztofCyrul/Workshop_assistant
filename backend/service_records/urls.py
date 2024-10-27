from django.urls import path
from service_records.views import VehicleServiceHistoryView, ClientServiceHistoryView

urlpatterns = [
    path('workshops/<uuid:workshop_pk>/vehicles/<uuid:vehicle_pk>/service-history/', VehicleServiceHistoryView.as_view(), name='vehicle-service-history'),
    path('workshops/<uuid:workshop_pk>/clients/<uuid:client_pk>/service-history/', ClientServiceHistoryView.as_view(), name='client-service-history'),
]
