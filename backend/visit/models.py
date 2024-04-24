from django.db import models
import string
import random

def generate_random_id():
    length = 6
    # Generuje losowy ciąg składający się z dużych liter i cyfr
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=length))

class CustomIDField(models.CharField):
    def __init__(self, *args, **kwargs):
        kwargs['max_length'] = 6  # Ustawienie stałej długości na 6 znaków
        kwargs['default'] = generate_random_id  # Ustawienie domyślnej funkcji generującej ID
        kwargs['editable'] = False  # Pole nie powinno być edytowane manualnie
        super().__init__(*args, **kwargs)

class ClientCar(models.Model):
    brand = models.CharField(max_length=50)
    model = models.CharField(max_length=50)
    year = models.IntegerField(null=True)
    vin = models.CharField(max_length=50, null=True)
    license_plate = models.CharField(max_length=50, null=True)
    client = models.ForeignKey('Client', on_delete=models.CASCADE)
    
    def __str__(self):
        return f'{self.brand} {self.model} {self.license_plate}'

class Client(models.Model):
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50, null=True, blank=True)
    email = models.CharField(max_length=50, null=True, blank=True)
    phone = models.CharField(max_length=50)
    address = models.CharField(max_length=50, null=True, blank=True)
    city = models.CharField(max_length=50, null=True, blank=True)
    state = models.CharField(max_length=50, null=True, blank=True)
    zip_code = models.CharField(max_length=50, null=True, blank=True)
        
    def __str__(self):
        return f'{self.first_name} {self.last_name}'
    
class Service(models.Model):
    id = CustomIDField(primary_key=True)
    date = models.DateField()
    name = models.CharField(max_length=50)
    description = models.TextField(null=True, blank=True)
    parts = models.TextField(null=True, blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    clients = models.ManyToManyField('Client', related_name='Services')
    cars = models.ManyToManyField('ClientCar', related_name='Services')
    mechanics = models.ManyToManyField('Mechanic', related_name='assigned_Services')
    
    def __str__(self):
        return f'{self.cars} - {self.date}'
    
class Mechanic(models.Model):
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    email = models.CharField(max_length=50, null=True, blank=True)
    phone = models.CharField(max_length=50, null=True, blank=True)
    address = models.CharField(max_length=50, null=True, blank=True)
    city = models.CharField(max_length=50, null=True, blank=True)
    state = models.CharField(max_length=50, null=True, blank=True)
    zip_code = models.CharField(max_length=50, null=True, blank=True)
    
    def __str__(self):
        return f'{self.first_name} {self.last_name}'

