# visit/serializers.py
from rest_framework import serializers
from .models import ClientCar, Client, Visit, Mechanic, Company

class ClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Client
        fields = '__all__'

class CompanySerializer(serializers.ModelSerializer):
    class Meta:
        model = Company
        fields = '__all__'

class CarSerializer(serializers.ModelSerializer):
    client = ClientSerializer()

    class Meta:
        model = ClientCar
        fields = '__all__'
        
    def create(self, validated_data):
        client_data = validated_data.pop('client')
        client, created = Client.objects.get_or_create(**client_data)
        car = ClientCar.objects.create(client=client, **validated_data)
        return car

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

class VisitClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Client
        fields = ['id', 'first_name', 'email', 'phone']

class VisitCarSerializer(serializers.ModelSerializer):
    client = VisitClientSerializer()

    class Meta:
        model = ClientCar
        fields = ['id', 'brand', 'model', 'year', 'vin', 'license_plate', 'client', 'company']

class VisitMechanicSerializer(serializers.ModelSerializer):
    class Meta:
        model = Mechanic
        fields = ['id', 'first_name', 'last_name']

class ClientVisitSerializer(serializers.ModelSerializer):
    cars = CarSerializer(many=True)
    mechanics = MechanicSerializer(many=True)

    class Meta:
        model = Visit
        fields = '__all__'

    def create(self, validated_data):
        cars_data = validated_data.pop('cars')
        mechanics_data = validated_data.pop('mechanics')
        visit = Visit.objects.create(**validated_data)

        for car_data in cars_data:
            client_data = car_data.pop('client')
            client, created = Client.objects.get_or_create(**client_data)
            car, created = ClientCar.objects.get_or_create(client=client, **car_data)
            visit.cars.add(car)

        for mechanic_data in mechanics_data:
            mechanic, created = Mechanic.objects.get_or_create(**mechanic_data)
            visit.mechanics.add(mechanic)

        return visit

    def update(self, instance, validated_data):
        cars_data = validated_data.pop('cars', None)
        mechanics_data = validated_data.pop('mechanics', None)

        instance.date = validated_data.get('date', instance.date)
        instance.name = validated_data.get('name', instance.name)
        instance.description = validated_data.get('description', instance.description)
        instance.parts = validated_data.get('parts', instance.parts)
        instance.price = validated_data.get('price', instance.price)
        instance.status = validated_data.get('status', instance.status)
        instance.striked_lines = validated_data.get('striked_lines', instance.striked_lines)
        instance.save()

        if cars_data is not None:
            instance.cars.clear()
            for car_data in cars_data:
                client_data = car_data.pop('client')
                client, created = Client.objects.get_or_create(**client_data)
                car, created = ClientCar.objects.get_or_create(client=client, **car_data)
                instance.cars.add(car)

        if mechanics_data is not None:
            instance.mechanics.clear()
            for mechanic_data in mechanics_data:
                mechanic, created = Mechanic.objects.get_or_create(**mechanic_data)
                instance.mechanics.add(mechanic)

        return instance