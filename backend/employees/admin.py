# employees/admin.py

from django.contrib import admin
from employees.models import Employee, ScheduleEntry

@admin.register(Employee)
class EmployeeAdmin(admin.ModelAdmin):
    list_display = ('user', 'workshop', 'position', 'hire_date')
    search_fields = ('user__email', 'workshop__name', 'position')

@admin.register(ScheduleEntry)
class ScheduleEntryAdmin(admin.ModelAdmin):
    list_display = ('employee', 'start_time', 'end_time')
    search_fields = ('employee__user__email',)
