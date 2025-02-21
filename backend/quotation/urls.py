from django.urls import path
from .views import (
    QuotationViewSet,
    QuotationRepairItemViewSet,
    QuotationPartViewSet,
)

# Definiowanie widoków dla QuotationViewSet
quotation_list = QuotationViewSet.as_view({'get': 'list', 'post': 'create'})
quotation_detail = QuotationViewSet.as_view({'get': 'retrieve', 'put': 'update', 'patch': 'partial_update', 'delete': 'destroy'})

# Definiowanie widoków dla QuotationRepairItemViewSet
quotation_repair_item_list = QuotationRepairItemViewSet.as_view({'get': 'list', 'post': 'create'})
quotation_repair_item_detail = QuotationRepairItemViewSet.as_view({'get': 'retrieve', 'put': 'update', 'patch': 'partial_update', 'delete': 'destroy'})

# Definiowanie widoków dla QuotationPartViewSet
quotation_part_list = QuotationPartViewSet.as_view({'get': 'list', 'post': 'create'})
quotation_part_detail = QuotationPartViewSet.as_view({'get': 'retrieve', 'put': 'update', 'patch': 'partial_update', 'delete': 'destroy'})

urlpatterns = [
    # Endpointy dla Quotation
    path('workshops/<uuid:workshop_pk>/quotations/', quotation_list, name='quotation-list'),
    path('workshops/<uuid:workshop_pk>/quotations/<uuid:pk>/', quotation_detail, name='quotation-detail'),

    # Endpointy dla QuotationRepairItem
    path('workshops/<uuid:workshop_pk>/quotations/<uuid:quotation_pk>/repair-items/', quotation_repair_item_list, name='quotation-repair-item-list'),
    path('workshops/<uuid:workshop_pk>/quotations/<uuid:quotation_pk>/repair-items/<uuid:pk>/', quotation_repair_item_detail, name='quotation-repair-item-detail'),

    # Endpointy dla QuotationPart
    path('workshops/<uuid:workshop_pk>/quotations/<uuid:quotation_pk>/parts/', quotation_part_list, name='quotation-part-list'),
    path('workshops/<uuid:workshop_pk>/quotations/<uuid:quotation_pk>/parts/<uuid:pk>/', quotation_part_detail, name='quotation-part-detail'),
]