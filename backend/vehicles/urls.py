from django.urls import path
from vehicles.views import VehicleViewSet

vehicle_list = VehicleViewSet.as_view({'get': 'list', 'post': 'create'})
vehicle_detail = VehicleViewSet.as_view({'get': 'retrieve', 'put': 'update', 'delete': 'destroy'})

urlpatterns = [
    path('workshops/<uuid:workshop_pk>/clients/<uuid:client_pk>/vehicles/', vehicle_list, name='vehicle-list'),
    path('workshops/<uuid:workshop_pk>/vehicles/<uuid:pk>/', vehicle_detail, name='vehicle-detail'),
]
