from rest_framework import serializers
from appointments.models import Appointment, RepairItem
from employees.models import Employee
from employees.serializers import EmployeeSerializer
from clients.models import Client
from vehicles.models import Vehicle
from clients.serializers import ClientSerializer
from vehicles.serializers import VehicleSerializer

class RepairItemSerializer(serializers.ModelSerializer):
    completed_by = EmployeeSerializer(read_only=True)
    completed_by_id = serializers.PrimaryKeyRelatedField(
        queryset=Employee.objects.all(),
        write_only=True,
        source='completed_by',
        allow_null=True,
        required=False
    )
    appointment = serializers.PrimaryKeyRelatedField(read_only=True)  # Upewnij się, że jest tylko do odczytu

    class Meta:
        model = RepairItem
        fields = (
            'id', 'appointment', 'description', 'is_completed', 'estimated_duration', 'actual_duration', 'cost',
            'completed_by', 'completed_by_id', 'status',
            'created_at', 'updated_at', 'order'
        )
        read_only_fields = ('id', 'appointment', 'estimated_duration', 'created_at', 'updated_at')

    def validate(self, attrs):
        appointment = self.context['appointment']
        completed_by = attrs.get('completed_by')

        if completed_by and completed_by.workshop != appointment.workshop:
            raise serializers.ValidationError("Pracownik nie należy do tego warsztatu.")

        return attrs

    def create(self, validated_data):
        appointment = self.context['appointment']
        validated_data.pop('appointment', None)  # Usuwa 'appointment' z validated_data
        return RepairItem.objects.create(appointment=appointment, **validated_data)



class AppointmentSerializer(serializers.ModelSerializer):
    client = ClientSerializer(read_only=True)
    vehicle = VehicleSerializer(read_only=True)
    repair_items = RepairItemSerializer(many=True, read_only=True)  # Dodanie pola do zagnieżdżenia RepairItem

    client_id = serializers.PrimaryKeyRelatedField(queryset=Client.objects.all(), write_only=True, source='client')
    vehicle_id = serializers.PrimaryKeyRelatedField(queryset=Vehicle.objects.all(), write_only=True, source='vehicle')

    class Meta:
        model = Appointment
        fields = (
            'id', 'workshop', 'client', 'client_id', 'vehicle', 'vehicle_id', 'assigned_mechanics', 
            'mileage', 'scheduled_time', 'status', 'notes', 'created_at', 'updated_at', 'repair_items' 
        )
        read_only_fields = ('id', 'workshop', 'client', 'vehicle', 'created_at', 'updated_at')

    def validate(self, attrs):
        workshop = self.context['workshop']
        client = attrs.get('client')
        vehicle = attrs.get('vehicle')
        if client.workshop != workshop:
            raise serializers.ValidationError("Klient nie należy do tego warsztatu.")

        if vehicle.client != client:
            raise serializers.ValidationError("Pojazd nie należy do wybranego klienta.")

        return attrs

    def update(self, instance, validated_data):
        previous_status = instance.status
        instance = super().update(instance, validated_data)
        new_status = instance.status

        if previous_status != 'completed' and new_status == 'completed':
            pass

        return instance

    def validate_mileage(self, value):
        if value < self.instance.vehicle.mileage:
            raise serializers.ValidationError("Przebieg nie może być mniejszy niż aktualny przebieg pojazdu.")
        return value
