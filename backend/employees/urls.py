# employees/urls.py

from django.urls import path
from employees.views import (
    EmployeeViewSet,
    EmployeeAssignRoleView,
    EmployeeRemoveRoleView,
    ScheduleEntryListCreateView,
    ScheduleEntryDetailView
)

employee_list = EmployeeViewSet.as_view({'get': 'list', 'post': 'create'})
employee_detail = EmployeeViewSet.as_view({'get': 'retrieve', 'put': 'update', 'delete': 'destroy'})

urlpatterns = [
    path('workshops/<uuid:workshop_pk>/employees/', employee_list, name='employee-list'),
    path('workshops/<uuid:workshop_pk>/employees/<uuid:pk>/', employee_detail, name='employee-detail'),
    path('workshops/<uuid:workshop_pk>/employees/<uuid:employee_pk>/roles/', EmployeeAssignRoleView.as_view(), name='employee-assign-role'),
    path('workshops/<uuid:workshop_pk>/employees/<uuid:employee_pk>/roles/<uuid:role_pk>/', EmployeeRemoveRoleView.as_view(), name='employee-remove-role'),
    path('workshops/<uuid:workshop_pk>/employees/<uuid:employee_pk>/schedule/', ScheduleEntryListCreateView.as_view(), name='schedule-list-create'),
    path('workshops/<uuid:workshop_pk>/employees/<uuid:employee_pk>/schedule/<uuid:pk>/', ScheduleEntryDetailView.as_view(), name='schedule-detail'),
]
