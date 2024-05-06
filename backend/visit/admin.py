from django.contrib import admin
from .models import ClientCar, Client, Visit, Mechanic, Company

admin.site.register(ClientCar)
admin.site.register(Client)
admin.site.register(Visit)
admin.site.register(Mechanic)
admin.site.register(Company)

# Register your models here.
