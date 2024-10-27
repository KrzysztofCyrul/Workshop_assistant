from rest_framework import serializers
from appointments.models import Appointment
from clients.models import Client
from vehicles.models import Vehicle
from workshops.models import Branch
from clients.serializers import ClientSerializer
from vehicles.serializers import VehicleSerializer
from workshops.serializers import BranchSerializer

class AppointmentSerializer(serializers.ModelSerializer):
    client = ClientSerializer(read_only=True)
    vehicle = VehicleSerializer(read_only=True)
    branch = BranchSerializer(read_only=True)

    client_id = serializers.PrimaryKeyRelatedField(queryset=Client.objects.all(), write_only=True, source='client')
    vehicle_id = serializers.PrimaryKeyRelatedField(queryset=Vehicle.objects.all(), write_only=True, source='vehicle')
    branch_id = serializers.PrimaryKeyRelatedField(queryset=Branch.objects.all(), write_only=True, source='branch', allow_null=True, required=False)

    class Meta:
        model = Appointment
        fields = (
            'id', 'workshop', 'branch', 'branch_id', 'client', 'client_id', 'vehicle', 'vehicle_id',
            'scheduled_time', 'status', 'notes', 'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'workshop', 'client', 'vehicle', 'branch', 'created_at', 'updated_at')


    def validate(self, attrs):
        workshop = self.context['workshop']
        client = attrs.get('client')
        vehicle = attrs.get('vehicle')
        branch = attrs.get('branch')

        if client.workshop != workshop:
            raise serializers.ValidationError("Klient nie należy do tego warsztatu.")

        if vehicle.client != client:
            raise serializers.ValidationError("Pojazd nie należy do wybranego klienta.")

        if branch and branch.workshop != workshop:
            raise serializers.ValidationError("Oddział nie należy do tego warsztatu.")

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