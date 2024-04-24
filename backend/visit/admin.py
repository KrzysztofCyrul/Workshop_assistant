from django.contrib import admin
from .models import ClientCar, Client, Service, Mechanic

admin.site.register(ClientCar)
admin.site.register(Client)
admin.site.register(Service)
admin.site.register(Mechanic)

# Register your models here.
