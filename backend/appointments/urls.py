from django.urls import path
from appointments.views import (
    AppointmentViewSet,
    RepairItemViewSet,
    GenerateRecommendationsAPIView,
    PartViewSet,
)

appointment_list = AppointmentViewSet.as_view({'get': 'list', 'post': 'create'})
appointment_detail = AppointmentViewSet.as_view({'get': 'retrieve', 'put': 'update', 'patch': 'partial_update', 'delete': 'destroy'})

repair_item_list = RepairItemViewSet.as_view({'get': 'list', 'post': 'create'})
repair_item_detail = RepairItemViewSet.as_view({'get': 'retrieve', 'put': 'update', 'patch': 'partial_update', 'delete': 'destroy'})

parts_list = PartViewSet.as_view({'get': 'list', 'post': 'create'})
parts_detail = PartViewSet.as_view({'get': 'retrieve', 'put': 'update', 'patch': 'partial_update', 'delete': 'destroy'})

urlpatterns = [
    path('workshops/<uuid:workshop_pk>/appointments/', appointment_list, name='appointment-list'),
    path('workshops/<uuid:workshop_pk>/appointments/<uuid:pk>/', appointment_detail, name='appointment-detail'),
    path('workshops/<uuid:workshop_pk>/appointments/<uuid:appointment_pk>/repair-items/', repair_item_list, name='repair-item-list'),
    path('workshops/<uuid:workshop_pk>/appointments/<uuid:appointment_pk>/repair-items/<uuid:pk>/', repair_item_detail, name='repair-item-detail'),
    path('workshops/<uuid:workshop_pk>/appointments/<uuid:appointment_pk>/recommendations/', GenerateRecommendationsAPIView.as_view(), name='generate-recommendations'),
    path('workshops/<uuid:workshop_pk>/appointments/<uuid:appointment_pk>/parts/', parts_list, name='parts-list'),
    path('workshops/<uuid:workshop_pk>/appointments/<uuid:appointment_pk>/parts/<uuid:pk>/', parts_detail, name='parts-detail'),
]
