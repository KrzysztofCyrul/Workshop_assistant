from django.urls import path
from service_orders.views import ServiceOrderViewSet

service_order_list = ServiceOrderViewSet.as_view({'get': 'list', 'post': 'create'})
service_order_detail = ServiceOrderViewSet.as_view({'get': 'retrieve', 'put': 'update', 'delete': 'destroy'})

urlpatterns = [
    path('workshops/<uuid:workshop_pk>/service-orders/', service_order_list, name='service-order-list'),
    path('workshops/<uuid:workshop_pk>/service-orders/<uuid:pk>/', service_order_detail, name='service-order-detail'),
]
