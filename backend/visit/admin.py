from django.contrib import admin
from .models import ClientCar, Client, Visit, Mechanic, Company, Part, Service

admin.site.register(ClientCar)
admin.site.register(Client)
admin.site.register(Visit)
admin.site.register(Mechanic)
admin.site.register(Company)
admin.site.register(Part)
admin.site.register(Service)
