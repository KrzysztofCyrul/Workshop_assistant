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
from django.contrib.auth.decorators import login_required

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
    
class CompaniesView(APIView):
    def get(self, request):
        companies = models.Company.objects.all()
        serializer = serializers.CompanySerializer(companies, many=True)
        return JsonResponse(serializer.data, safe=False)
    
    def post(self, request):
        data = JSONParser().parse(request)
        serializer = serializers.CompanySerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data, status=201)
        return JsonResponse(serializer.errors, status=400)
    
class CompanyDetailView(APIView):
    def get(self, request, id):
        try:
            company = models.Company.objects.get(id=id)
        except models.Company.DoesNotExist:
            return JsonResponse({'error': 'Company not found'}, status=404)
        
        serializer = serializers.CompanySerializer(company)
        return JsonResponse(serializer.data)
    
    def post(self, request, id):
        try:
            company = models.Company.objects.get(id=id)
        except models.Company.DoesNotExist:
            return JsonResponse({'error': 'Company not found'}, status=404)
        
        data = JSONParser().parse(request)
        serializer = serializers.CompanySerializer(company, data=data)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data)
        return JsonResponse(serializer.errors, status=400)
    
    def delete(self, request, id):
        try:
            company = models.Company.objects.get(id=id)
        except models.Company.DoesNotExist:
            return JsonResponse({'error': 'Company not found'}, status=404)
        
        company.delete()
        return JsonResponse({'message': 'Company was deleted successfully!'}, status=204)

class VisitView(APIView):
    def get(self, request):
        visits = models.visit.objects.all()
        serializer = serializers.VisitSerializer(visits, many=True)
        return JsonResponse(serializer.data, safe=False)
    
    def post(self, request):
        data = JSONParser().parse(request)
        serializer = serializers.VisitSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data, status=201)
        return JsonResponse(serializer.errors, status=400)

class VisitDetailView(APIView):
    def get(self, request, id):
        try:
            visit = models.Visit.objects.get(id=id)
        except models.Visit.DoesNotExist:
            return JsonResponse({'error': 'visit not found'}, status=404)
        
        serializer = serializers.VisitSerializer(visit)
        return JsonResponse(serializer.data)
    
    def post(self, request, id):
        try:
            visit = models.Visit.objects.get(id=id)
        except models.Visit.DoesNotExist:
            return JsonResponse({'error': 'visit not found'}, status=404)
        
        data = JSONParser().parse(request)
        serializer = serializers.VisitSerializer(visit, data=data)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data)
        return JsonResponse(serializer.errors, status=400)
    
    def delete(self, request, id):
        try:
            visit = models.Visit.objects.get(id=id)
        except models.Visit.DoesNotExist:
            return JsonResponse({'error': 'visit not found'}, status=404)
        
        visit.delete()
        return JsonResponse({'message': 'visit was deleted successfully!'}, status=204)

    
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
    
class ClientVisitView(APIView):
    def get(self, request):
        visits = models.Visit.objects.all()
        serializer = serializers.ClientVisitSerializer(visits, many=True)
        return JsonResponse(serializer.data, safe=False)
    def post(self, request):
        data = JSONParser().parse(request)
        serializer = serializers.ClientVisitSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data, status=201)
        return JsonResponse(serializer.errors, status=400)
    
class ClientVisitDetailView(APIView):
    def get(self, request, id):
        try:
            visit = models.Visit.objects.get(id=id)
        except models.Visit.DoesNotExist:
            return JsonResponse({'error': 'Visit not found'}, status=404)
        
        serializer = serializers.ClientVisitSerializer(visit)
        return JsonResponse(serializer.data)
    def post(self, request, id):
        try:
            visit = models.Visit.objects.get(id=id)
        except models.Visit.DoesNotExist:
            return JsonResponse({'error': 'Visit not found'}, status=404)
        
        data = JSONParser().parse(request)
        serializer = serializers.ClientVisitSerializer(visit, data=data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse(serializer.data)
        return JsonResponse(serializer.errors, status=400)

class UpdateStrikedLines(APIView):
    def post(self, request, pk, format=None):
        try:
            visit = models.Visit.objects.get(pk=pk)
            striked_lines = request.data.get('strikedLines', {})  # Pobierz nowy format słownika
            visit.striked_lines = striked_lines
            visit.save()
            return JsonResponse({'status': 'striked lines updated'})
        except models.Visit.DoesNotExist:
            return JsonResponse({'error': 'Visit not found'}, status=404)

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