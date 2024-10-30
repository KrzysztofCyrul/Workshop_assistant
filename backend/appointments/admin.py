from django.contrib import admin
from appointments.models import Appointment, RepairItem

@admin.register(Appointment)
class AppointmentAdmin(admin.ModelAdmin):
    list_display = ('client', 'vehicle', 'scheduled_time', 'status')
    search_fields = ('client__first_name', 'client__last_name', 'vehicle__license_plate', 'status')
    list_filter = ('status', 'scheduled_time')

@admin.register(RepairItem)
class RepairItemAdmin(admin.ModelAdmin):
    list_display = ('appointment', 'description', 'status')
    search_fields = ('appointment__client__first_name', 'appointment__client__last_name', 'description', 'status')
    list_filter = ('status',)