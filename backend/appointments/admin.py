from pyexpat.errors import messages
from django.contrib import admin
from appointments.models import Appointment, RepairItem
from ai_module.signals import get_appointment_recommendations

@admin.register(Appointment)
class AppointmentAdmin(admin.ModelAdmin):
    list_display = ('client', 'vehicle', 'scheduled_time', 'status')
    search_fields = ('client__first_name', 'client__last_name', 'vehicle__license_plate', 'status')
    readonly_fields = ('estimated_duration',)
    list_filter = ('status', 'scheduled_time')
    actions = ['generate_recommendations']
    
    def generate_recommendations(self, request, queryset):
        for appointment in queryset:
            repair_items = appointment.repair_items.all()
            appointment_description = appointment.notes or "Brak opisu wizyty."

            recommendations = get_appointment_recommendations(appointment_description, repair_items)

            if recommendations:
                appointment.recommendations = recommendations
                appointment.save()
                self.message_user(request, f"Zaktualizowano recommendations dla wizyty {appointment}.")
            else:
                self.message_user(request, f"Nie udało się uzyskać recommendations dla wizyty {appointment}.", level=messages.ERROR)

    generate_recommendations.short_description = "Wygeneruj sugestie i wskazówki"

@admin.register(RepairItem)
class RepairItemAdmin(admin.ModelAdmin):
    list_display = ('appointment', 'description', 'status')
    search_fields = ('appointment__client__first_name', 'appointment__client__last_name', 'description', 'status')
    readonly_fields = ('estimated_duration',)
    list_filter = ('status',)
