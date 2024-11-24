from django.contrib import admin
from workshops.models import Workshop

@admin.register(Workshop)
class WorkshopAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'owner', 'address', 'created_at')
    search_fields = ('name', 'owner__email', 'address')
