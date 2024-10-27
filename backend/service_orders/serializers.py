from rest_framework import serializers
from service_orders.models import ServiceOrder
from clients.models import Client
from vehicles.models import Vehicle
from workshops.models import Branch
from employees.models import Employee
from appointments.models import Appointment

class ServiceOrderSerializer(serializers.ModelSerializer):
    client = serializers.PrimaryKeyRelatedField(queryset=Client.objects.all())
    vehicle = serializers.PrimaryKeyRelatedField(queryset=Vehicle.objects.all())
    branch = serializers.PrimaryKeyRelatedField(queryset=Branch.objects.all(), allow_null=True, required=False)
    assigned_to = serializers.PrimaryKeyRelatedField(queryset=Employee.objects.all(), allow_null=True, required=False)
    appointment = serializers.PrimaryKeyRelatedField(queryset=Appointment.objects.all(), allow_null=True, required=False)
    
    class Meta:
        model = ServiceOrder
        fields = (
            'id', 'appointment', 'workshop', 'branch', 'client', 'vehicle',
            'assigned_to', 'status', 'total_cost', 'notes', 'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'workshop', 'created_at', 'updated_at')

    def validate(self, attrs):
        workshop = self.context['workshop']
        client = attrs.get('client')
        vehicle = attrs.get('vehicle')
        branch = attrs.get('branch')
        assigned_to = attrs.get('assigned_to')
        appointment = attrs.get('appointment')

        if client.workshop != workshop:
            raise serializers.ValidationError("Klient nie należy do tego warsztatu.")

        if vehicle.client != client:
            raise serializers.ValidationError("Pojazd nie należy do wybranego klienta.")

        if branch and branch.workshop != workshop:
            raise serializers.ValidationError("Oddział nie należy do tego warsztatu.")

        if assigned_to and assigned_to.workshop != workshop:
            raise serializers.ValidationError("Pracownik nie należy do tego warsztatu.")

        if appointment and appointment.workshop != workshop:
            raise serializers.ValidationError("Wizyta nie należy do tego warsztatu.")

        return attrs

    def create(self, validated_data):
        workshop = self.context['workshop']
        return ServiceOrder.objects.create(workshop=workshop, **validated_data)
