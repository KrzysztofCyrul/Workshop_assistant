from django.contrib import admin
from clients.models import Client

@admin.register(Client)
class ClientAdmin(admin.ModelAdmin):
    list_display = ('first_name', 'last_name', 'email', 'phone', 'workshop')
    readonly_fields = ('segment', 'discount')
    search_fields = ('first_name', 'last_name', 'email', 'phone', 'workshop__name')
