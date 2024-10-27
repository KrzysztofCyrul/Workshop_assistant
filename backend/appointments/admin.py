from django.contrib import admin
from appointments.models import Appointment

@admin.register(Appointment)
class AppointmentAdmin(admin.ModelAdmin):
    list_display = ('client', 'vehicle', 'scheduled_time', 'status')
    search_fields = ('client__first_name', 'client__last_name', 'vehicle__license_plate', 'status')
    list_filter = ('status', 'scheduled_time')
