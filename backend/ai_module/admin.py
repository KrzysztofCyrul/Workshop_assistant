from django.contrib import admin
from ai_module.models import TrainingData

@admin.register(TrainingData)
class TrainingDataAdmin(admin.ModelAdmin):
    list_per_page = 2300
    list_display = ('description', 'make', 'model', 'year', 'engine', 'actual_duration_hours')
    search_fields = ('description', 'make', 'model', 'year', 'engine', 'actual_duration_hours')
    list_filter = ('make', 'model', 'year', 'engine', 'actual_duration_hours')
    
