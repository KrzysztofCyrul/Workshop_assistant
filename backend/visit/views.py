from django.http import JsonResponse
from django.http import HttpResponse
from django.views.generic import View
from rest_framework.views import APIView
from rest_framework.decorators import api_view
from rest_framework.parsers import JSONParser
from . import models
from . import serializers
import random
import string
from .models import Client
    
class CarsView(APIView):
    def get(self, request):
        cars = models.ClientCar.objects.all()
        serializer = serializers.CarSerializer(cars, many=True)
        return JsonResponse(serializer.data, safe=False)
    
    def post(self, request):
        data = JSONParser().parse(request)
        serializer = serializers.CarSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data, status=201)
        return JsonResponse(serializer.errors, status=400)
    
class CarDetailView(APIView):
    def get(self, request, id):
        try:
            car = models.ClientCar.objects.get(id=id)
        except models.ClientCar.DoesNotExist:
            return JsonResponse({'error': 'Car not found'}, status=404)
        
        serializer = serializers.CarSerializer(car)
        return JsonResponse(serializer.data)
    
    def post(self, request, id):
        try:
            car = models.ClientCar.objects.get(id=id)
        except models.ClientCar.DoesNotExist:
            return JsonResponse({'error': 'Car not found'}, status=404)
        
        data = JSONParser().parse(request)
        serializer = serializers.CarSerializer(car, data=data)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data)
        return JsonResponse(serializer.errors, status=400)
    
    def delete(self, request, id):
        try:
            car = models.ClientCar.objects.get(id=id)
        except models.ClientCar.DoesNotExist:
            return JsonResponse({'error': 'Car not found'}, status=404)
        
        car.delete()
        return JsonResponse({'message': 'Car was deleted successfully!'}, status=204)    
    
class ClientsView(APIView):
    def get(self, request):
        clients = models.Client.objects.all()
        serializer = serializers.ClientSerializer(clients, many=True)
        return JsonResponse(serializer.data, safe=False)
    
    def post(self, request):
        data = JSONParser().parse(request)
        serializer = serializers.ClientSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data, status=201)
        return JsonResponse(serializer.errors, status=400)
    
class ClientDetailView(APIView):
    def get(self, request, id):
        try:
            client = models.Client.objects.get(id=id)
        except models.Client.DoesNotExist:
            return JsonResponse({'error': 'Client not found'}, status=404)
        
        serializer = serializers.ClientSerializer(client)
        return JsonResponse(serializer.data)
    
    def post(self, request, id):
        try:
            client = models.Client.objects.get(id=id)
        except models.Client.DoesNotExist:
            return JsonResponse({'error': 'Client not found'}, status=404)
        
        data = JSONParser().parse(request)
        serializer = serializers.ClientSerializer(client, data=data)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data)
        return JsonResponse(serializer.errors, status=400)
    
    def delete(self, request, id):
        try:
            client = models.Client.objects.get(id=id)
        except models.Client.DoesNotExist:
            return JsonResponse({'error': 'Client not found'}, status=404)
        
        client.delete()
        return JsonResponse({'message': 'Client was deleted successfully!'}, status=204)

class ServicesView(APIView):
    def get(self, request):
        services = models.Service.objects.all()
        serializer = serializers.ServiceSerializer(services, many=True)
        return JsonResponse(serializer.data, safe=False)
    
    def post(self, request):
        data = JSONParser().parse(request)
        serializer = serializers.ServiceSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data, status=201)
        return JsonResponse(serializer.errors, status=400)

class ServiceDetailView(APIView):
    def get(self, request, id):
        try:
            service = models.Service.objects.get(id=id)
        except models.Service.DoesNotExist:
            return JsonResponse({'error': 'Service not found'}, status=404)
        
        serializer = serializers.ServiceSerializer(service)
        return JsonResponse(serializer.data)
    
    def post(self, request, id):
        try:
            service = models.Service.objects.get(id=id)
        except models.Service.DoesNotExist:
            return JsonResponse({'error': 'Service not found'}, status=404)
        
        data = JSONParser().parse(request)
        serializer = serializers.ServiceSerializer(service, data=data)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data)
        return JsonResponse(serializer.errors, status=400)
    
    def delete(self, request, id):
        try:
            service = models.Service.objects.get(id=id)
        except models.Service.DoesNotExist:
            return JsonResponse({'error': 'Service not found'}, status=404)
        
        service.delete()
        return JsonResponse({'message': 'Service was deleted successfully!'}, status=204)
    
class MechanicsView(APIView):
    def get(self, request):
        mechanics = models.Mechanic.objects.all()
        serializer = serializers.MechanicSerializer(mechanics, many=True)
        return JsonResponse(serializer.data, safe=False)
    
    def post(self, request):
        data = JSONParser().parse(request)
        serializer = serializers.MechanicSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data, status=201)
        return JsonResponse(serializer.errors, status=400)

class MechanicDetailView(APIView):
    def get(self, request, id):
        try:
            mechanic = models.Mechanic.objects.get(id=id)
        except models.Mechanic.DoesNotExist:
            return JsonResponse({'error': 'Mechanic not found'}, status=404)
        
        serializer = serializers.MechanicSerializer(mechanic)
        return JsonResponse(serializer.data)
    
    def post(self, request, id):
        try:
            mechanic = models.Mechanic.objects.get(id=id)
        except models.Mechanic.DoesNotExist:
            return JsonResponse({'error': 'Mechanic not found'}, status=404)
        
        data = JSONParser().parse(request)
        serializer = serializers.MechanicSerializer(mechanic, data=data)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data)
        return JsonResponse(serializer.errors, status=400)
    
    def delete(self, request, id):
        try:
            mechanic = models.Mechanic.objects.get(id=id)
        except models.Mechanic.DoesNotExist:
            return JsonResponse({'error': 'Mechanic not found'}, status=404)
        
        mechanic.delete()
        return JsonResponse({'message': 'Mechanic was deleted successfully!'}, status=204) 


def generate_random_clients(request):
    first_names = ["Krzysztof", "Anna", "Jan", "Maria", "Piotr", "Agnieszka"]
    last_names = ["Nowak", "Kowalski", "Wiśniewski", "Dąbrowski", "Lewandowski", "Wójcik"]
    cities = ["Warszawa", "Kraków", "Łódź", "Wrocław", "Poznań", "Gdańsk"]
    states = ["mazowieckie", "małopolskie", "łódzkie", "dolnośląskie", "wielkopolskie", "pomorskie"]

    for _ in range(10):  # Tworzenie 10 klientów
        first_name = random.choice(first_names)
        last_name = random.choice(last_names)
        email = f"{first_name.lower()}.{last_name.lower()}_{random.randint(1, 100)}@gmail.com"
        phone = ''.join(random.choices(string.digits, k=9))
        address = ''.join(random.choices(string.ascii_letters + string.digits, k=random.randint(5, 20)))
        city = random.choice(cities)
        state = random.choice(states)
        zip_code = ''.join(random.choices(string.digits, k=5))

        client = Client.objects.create(
            first_name=first_name,
            last_name=last_name,
            email=email,
            phone=phone,
            address=address,
            city=city,
            state=state,
            zip_code=zip_code
        )
        client.save()

    return JsonResponse({"message": "Random clients generated successfully."})


def sort_clients(request):
    clients = models.Client.objects.all()
    sorted_clients = sorted(clients, key=lambda x: x.last_name)
    serializer = serializers.ClientSerializer(sorted_clients, many=True)
    return JsonResponse(serializer.data)