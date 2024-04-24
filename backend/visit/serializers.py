from rest_framework import serializers
from .models import ClientCar, Client, Service, Mechanic

class CarSerializer(serializers.ModelSerializer):
    class Meta:
        model = ClientCar
        fields = '__all__'
        
class ClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Client
        fields = '__all__'

class ServiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Service
        fields = '__all__'

class MechanicSerializer(serializers.ModelSerializer):
    class Meta:
        model = Mechanic
        fields = '__all__'