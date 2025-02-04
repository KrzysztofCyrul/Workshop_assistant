from django.urls import path
from employees.views import (
    EmployeeViewSet,
    EmployeeAssignRoleView,
    EmployeeRemoveRoleView,
    GenerateTemporaryCodeView,
    ScheduleEntryListCreateView,
    ScheduleEntryDetailView,
    RequestAssignmentView,
    ApproveAssignmentView,
    PendingAssignmentListView,
    UseTemporaryCodeView,
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
    path('workshops/<uuid:workshop_id>/request-assignment/', RequestAssignmentView.as_view(), name='request-assignment'),
    path('employees/<uuid:employee_id>/approve-assignment/', ApproveAssignmentView.as_view(), name='approve-assignment'),
    path('workshops/<uuid:workshop_id>/pending-requests/', PendingAssignmentListView.as_view(), name='pending-requests'),
    path('workshops/<uuid:workshop_id>/generate-code/', GenerateTemporaryCodeView.as_view(), name='generate-temporary-code'),
    path('use-code/', UseTemporaryCodeView.as_view(), name='use-temporary-code'),
]

