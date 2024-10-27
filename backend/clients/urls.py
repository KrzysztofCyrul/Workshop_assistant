from django.urls import path
from clients.views import ClientViewSet

client_list = ClientViewSet.as_view({'get': 'list', 'post': 'create'})
client_detail = ClientViewSet.as_view({'get': 'retrieve', 'put': 'update', 'delete': 'destroy'})

urlpatterns = [
    path('workshops/<uuid:workshop_pk>/clients/', client_list, name='client-list'),
    path('workshops/<uuid:workshop_pk>/clients/<uuid:pk>/', client_detail, name='client-detail'),
]
