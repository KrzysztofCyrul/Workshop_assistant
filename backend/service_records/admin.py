from django.contrib import admin
from service_records.models import ServiceRecord

@admin.register(ServiceRecord)
class ServiceRecordAdmin(admin.ModelAdmin):
    list_display = ('vehicle', 'date', 'mileage')
    search_fields = ('vehicle__make', 'vehicle__model', 'vehicle__license_plate')
