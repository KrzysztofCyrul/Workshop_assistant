from django.urls import path
from service_tasks.views import ServiceTaskViewSet

task_list = ServiceTaskViewSet.as_view({'get': 'list', 'post': 'create'})
task_detail = ServiceTaskViewSet.as_view({'get': 'retrieve', 'put': 'update', 'delete': 'destroy'})

urlpatterns = [
    path('workshops/<uuid:workshop_pk>/service-orders/<uuid:order_pk>/tasks/', task_list, name='service-task-list'),
    path('workshops/<uuid:workshop_pk>/service-orders/<uuid:order_pk>/tasks/<uuid:pk>/', task_detail, name='service-task-detail'),
]
