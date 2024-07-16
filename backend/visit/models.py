from django.db import models
import string
import random

# Status
status = (
    ('pending', 'Oczekujące'),
    ('in_progress', 'W trakcie'),
    ('done', 'Zakończone'),
    ('archived', 'Zarchiwizowane'),
)

# Random id generator
def generate_random_id():
    length = 6
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=length))

# Custom ID field
class CustomIDField(models.CharField):
    def __init__(self, *args, **kwargs):
        kwargs['max_length'] = 6  # Ustawienie stałej długości na 6 znaków
        kwargs['default'] = generate_random_id  # Ustawienie domyślnej funkcji generującej ID
        kwargs['editable'] = False  # Pole nie powinno być edytowane manualnie
        super().__init__(*args, **kwargs)

class ClientCar(models.Model):
    brand = models.CharField(max_length=50)
    model = models.CharField(max_length=50, null=True, blank=True)
    year = models.IntegerField(null=True, blank=True)
    vin = models.CharField(max_length=50, null=True, blank=True)
    license_plate = models.CharField(max_length=50, null=True, blank=True)
    client = models.ForeignKey('Client', on_delete=models.CASCADE, null=True, blank=True)
    company = models.ForeignKey('Company', on_delete=models.CASCADE, null=True, blank=True)
    
    def __str__(self):
        return f'{self.brand} {self.model} {self.license_plate}'
    
class Client(models.Model):
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50, null=True, blank=True)
    email = models.CharField(max_length=50, null=True, blank=True)
    phone = models.CharField(max_length=50, null=True, blank=True)
    address = models.CharField(max_length=50, null=True, blank=True)
    city = models.CharField(max_length=50, null=True, blank=True)
    state = models.CharField(max_length=50, null=True, blank=True)
    zip_code = models.CharField(max_length=50, null=True, blank=True)
        
    def __str__(self):
        return f'{self.first_name} {self.last_name}'

# Klasa reprezentująca firmę    
class Company(models.Model):
    name = models.CharField(max_length=50)
    nip = models.CharField(max_length=50, null=True, blank=True)
    regon = models.CharField(max_length=50, null=True, blank=True)
    email = models.CharField(max_length=50, null=True, blank=True)
    phone = models.CharField(max_length=50, null=True, blank=True)
    address = models.CharField(max_length=50, null=True, blank=True)
    city = models.CharField(max_length=50, null=True, blank=True)
    state = models.CharField(max_length=50, null=True, blank=True)
    zip_code = models.CharField(max_length=50, null=True, blank=True)
    
    def __str__(self):
        return f'{self.name}'

# Klasa reprezentująca serwis    
class Visit(models.Model):
    id = CustomIDField(primary_key=True)
    date = models.DateField()
    name = models.CharField(max_length=50)
    description = models.TextField(null=True, blank=True)
    service = models.TextField(null=True, blank=True)
    parts = models.TextField(null=True, blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    cars = models.ManyToManyField('ClientCar', related_name='Services', blank=True)
    mechanics = models.ManyToManyField('Mechanic', related_name='assigned_Services', blank=True)
    status = models.CharField(max_length=50, choices=status, default='pending')
    striked_lines = models.JSONField(default=dict, blank=True)  # Lista indeksów przekreślonych linii


    def __str__(self):
        return f' {self.date} {self.id} {self.name} '
 
 # Klasa reprezentująca mechanika   
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

class Part(models.Model):
    name = models.CharField(max_length=255)
    price = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f'{self.name} {self.price}'

class Service(models.Model):
    name = models.CharField(max_length=255)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    parts = models.ManyToManyField(Part, blank=True)

    def __str__(self):
        return f'{self.name} {self.price}'
    
class Estimate(models.Model):
    id = CustomIDField(primary_key=True)
    date = models.DateField()
    name = models.CharField(max_length=50)
    description = models.TextField(null=True, blank=True)
    parts = models.TextField(null=True, blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    cars = models.ManyToManyField('ClientCar', related_name='Estimates', blank=True)
    mechanics = models.ManyToManyField('Mechanic', related_name='assigned_Estimates', blank=True)
    status = models.CharField(max_length=50, choices=status, default='pending')
    striked_lines = models.JSONField(default=dict, blank=True)  # Lista indeksów przekreślonych linii

    def __str__(self):
        return f'{self.date} {self.id} {self.name}'