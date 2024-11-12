from django.contrib import admin
from workshops.models import Workshop, Branch

@admin.register(Workshop)
class WorkshopAdmin(admin.ModelAdmin):
    list_display = ('id','name', 'owner', 'address', 'created_at')
    search_fields = ('name', 'owner__email', 'address')

@admin.register(Branch)
class BranchAdmin(admin.ModelAdmin):
    list_display = ('name', 'workshop', 'address', 'phone', 'email')
    search_fields = ('name', 'workshop__name', 'address')
