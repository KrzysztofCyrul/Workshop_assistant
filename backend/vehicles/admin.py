from django.contrib import admin
from vehicles.models import Vehicle

@admin.register(Vehicle)
class VehicleAdmin(admin.ModelAdmin):
    list_display = ('make', 'model', 'license_plate', 'client')
    search_fields = ('make', 'model', 'license_plate', 'client__first_name', 'client__last_name')
