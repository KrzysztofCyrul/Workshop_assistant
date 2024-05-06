from rest_framework import serializers
from .models import ClientCar, Client, Visit, Mechanic

       
class ClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Client
        fields = '__all__'

class CarSerializer(serializers.ModelSerializer):
    client = ClientSerializer()

    class Meta:
        model = ClientCar
        fields = '__all__'
 
class MechanicSerializer(serializers.ModelSerializer):
    class Meta:
        model = Mechanic
        fields = '__all__'
        
class VisitSerializer(serializers.ModelSerializer):
    cars = CarSerializer(many=True)
    mechanics = MechanicSerializer(many=True)
    
    class Meta:
        model = Visit
        fields = '__all__'

class VisitCarSerializer(serializers.ModelSerializer):
    class Meta:
        model = ClientCar
        fields = ['id', 'brand', 'model', 'year', 'vin', 'license_plate']
        
class VisitClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Client
        fields = ['id', 'first_name','email', 'phone']
        
class VisitMechanicSerializer(serializers.ModelSerializer):
    class Meta:
        model = Mechanic
        fields = ['id', 'first_name', 'last_name']
        
class ClientVisitSerializer(serializers.ModelSerializer):
    cars = VisitCarSerializer(many=True)
    clients = VisitClientSerializer(many=True)
    mechanics = VisitMechanicSerializer(many=True)
    
    class Meta:
        model = Visit
        fields = ['id', 'date', 'name', 'description', 'parts', 'price', 'cars', 'mechanics', 'clients', 'status']
        