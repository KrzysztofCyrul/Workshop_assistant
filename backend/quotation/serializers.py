from rest_framework import serializers
from .models import Quotation, QuotationPart
from clients.models import Client
from vehicles.models import Vehicle
from clients.serializers import ClientSerializer
from vehicles.serializers import VehicleSerializer

class QuotationPartSerializer(serializers.ModelSerializer):
    class Meta:
        model = QuotationPart
        fields = '__all__'
        read_only_fields = ('id', 'quotation', 'created_at', 'updated_at')

    def validate_quantity(self, value):
        if value <= 0:
            raise serializers.ValidationError("Ilość musi być większa niż 0.")
        return value

    def validate_cost_part(self, value):
        if value < 0:
            raise serializers.ValidationError("Cena nie może być ujemna.")
        return value

    def create(self, validated_data):
        validated_data['quotation'] = self.context['quotation']
        return super().create(validated_data)


class QuotationSerializer(serializers.ModelSerializer):
    client = ClientSerializer(read_only=True)
    vehicle = VehicleSerializer(read_only=True)
    quotation_parts = QuotationPartSerializer(many=True, read_only=True) 

    client_id = serializers.PrimaryKeyRelatedField(queryset=Client.objects.all(), write_only=True, source='client')
    vehicle_id = serializers.PrimaryKeyRelatedField(queryset=Vehicle.objects.all(), write_only=True, source='vehicle')

    class Meta:
        model = Quotation
        fields = '__all__'
        read_only_fields = ('id', 'quotation_number', 'created_at', 'updated_at')

    def validate(self, data):
        client = data.get('client')
        vehicle = data.get('vehicle')

        return data

    def create(self, validated_data):
        # Tworzenie wyceny
        quotation = Quotation.objects.create(**validated_data)
        return quotation

    def update(self, instance, validated_data):
        # Aktualizacja wyceny
        instance = super().update(instance, validated_data)
        return instance