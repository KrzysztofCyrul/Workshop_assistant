from django.urls import path
from .views import (
    QuotationViewSet,
    QuotationPartViewSet,
)

# Definiowanie widoków dla QuotationViewSet
quotation_list = QuotationViewSet.as_view({'get': 'list', 'post': 'create'})
quotation_detail = QuotationViewSet.as_view({'get': 'retrieve', 'put': 'update', 'patch': 'partial_update', 'delete': 'destroy'})

# Definiowanie widoków dla QuotationPartViewSet
quotation_part_list = QuotationPartViewSet.as_view({'get': 'list', 'post': 'create'})
quotation_part_detail = QuotationPartViewSet.as_view({'get': 'retrieve', 'put': 'update', 'patch': 'partial_update', 'delete': 'destroy'})

urlpatterns = [
    # Endpointy dla Quotation
    path('workshops/<uuid:workshop_pk>/quotations/', quotation_list, name='quotation-list'),
    path('workshops/<uuid:workshop_pk>/quotations/<uuid:pk>/', quotation_detail, name='quotation-detail'),

    # Endpointy dla QuotationPart
    path('workshops/<uuid:workshop_pk>/quotations/<uuid:quotation_pk>/parts/', quotation_part_list, name='quotation-part-list'),
    path('workshops/<uuid:workshop_pk>/quotations/<uuid:quotation_pk>/parts/<uuid:pk>/', quotation_part_detail, name='quotation-part-detail'),
]