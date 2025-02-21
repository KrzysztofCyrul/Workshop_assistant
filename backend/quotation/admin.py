from django.contrib import admin
from django.utils.html import format_html
from .models import Quotation, QuotationRepairItem, QuotationPart

@admin.register(Quotation)
class QuotationAdmin(admin.ModelAdmin):
    list_display = ('quotation_number', 'client', 'vehicle', 'workshop', 'created_at', 'total_cost_display')
    list_filter = ('workshop', 'created_at', 'client')
    search_fields = ('quotation_number', 'client__name', 'vehicle__model')
    readonly_fields = ('quotation_number', 'created_at', 'updated_at')
    fieldsets = (
        (None, {
            'fields': ('quotation_number', 'client', 'vehicle', 'workshop')
        }),
        ('Details', {
            'fields': ('total_cost', 'created_at', 'updated_at')
        }),
    )

    def total_cost_display(self, obj):
        return f"{obj.total_cost} PLN" if obj.total_cost else "Brak danych"
    total_cost_display.short_description = 'Całkowity koszt'

    def get_readonly_fields(self, request, obj=None):
        # Ustawia pola jako read-only podczas edycji
        if obj:  # Jeśli obiekt już istnieje (edycja)
            return self.readonly_fields + ('client', 'vehicle', 'workshop')
        return self.readonly_fields


@admin.register(QuotationRepairItem)
class QuotationRepairItemAdmin(admin.ModelAdmin):
    list_display = ('description', 'quotation', 'cost_display', 'created_at')
    list_filter = ('quotation__workshop', 'quotation__client')
    search_fields = ('description', 'quotation__quotation_number')
    readonly_fields = ('created_at', 'updated_at')

    def cost_display(self, obj):
        return f"{obj.cost} PLN"
    cost_display.short_description = 'Koszt'

    def get_queryset(self, request):
        # Optymalizacja zapytań do bazy danych
        return super().get_queryset(request).select_related('quotation')


@admin.register(QuotationPart)
class QuotationPartAdmin(admin.ModelAdmin):
    list_display = ('name', 'quotation', 'quantity', 'total_cost_display', 'created_at')
    list_filter = ('quotation__workshop', 'quotation__client')
    search_fields = ('name', 'quotation__quotation_number')
    readonly_fields = ('created_at', 'updated_at')

    def total_cost_display(self, obj):
        return f"{obj.total_cost} PLN"
    total_cost_display.short_description = 'Całkowity koszt'

    def get_queryset(self, request):
        # Optymalizacja zapytań do bazy danych
        return super().get_queryset(request).select_related('quotation')