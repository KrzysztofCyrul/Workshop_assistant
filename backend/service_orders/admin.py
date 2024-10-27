from django.contrib import admin
from service_orders.models import ServiceOrder

@admin.register(ServiceOrder)
class ServiceOrderAdmin(admin.ModelAdmin):
    list_display = ('id', 'workshop', 'client', 'vehicle', 'assigned_to', 'status', 'total_cost')
    search_fields = ('client__first_name', 'client__last_name', 'vehicle__license_plate', 'status')
    list_filter = ('status', 'created_at')
