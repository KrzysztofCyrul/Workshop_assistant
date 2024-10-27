from django.urls import path
from appointments.views import AppointmentViewSet

appointment_list = AppointmentViewSet.as_view({'get': 'list', 'post': 'create'})
appointment_detail = AppointmentViewSet.as_view({'get': 'retrieve', 'put': 'update', 'delete': 'destroy'})

urlpatterns = [
    path('workshops/<uuid:workshop_pk>/appointments/', appointment_list, name='appointment-list'),
    path('workshops/<uuid:workshop_pk>/appointments/<uuid:pk>/', appointment_detail, name='appointment-detail'),
]
