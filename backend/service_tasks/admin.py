from django.contrib import admin
from service_tasks.models import ServiceTask

@admin.register(ServiceTask)
class ServiceTaskAdmin(admin.ModelAdmin):
    list_display = ('id', 'service_order', 'assigned_to', 'status', 'estimated_time', 'actual_time')
    search_fields = ('service_order__id', 'assigned_to__user__first_name', 'assigned_to__user__last_name', 'status')
    list_filter = ('status', 'created_at')
