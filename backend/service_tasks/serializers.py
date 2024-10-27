from rest_framework import serializers
from service_tasks.models import ServiceTask
from employees.models import Employee

class ServiceTaskSerializer(serializers.ModelSerializer):
    assigned_to = serializers.PrimaryKeyRelatedField(queryset=Employee.objects.all(), allow_null=True, required=False)

    class Meta:
        model = ServiceTask
        fields = (
            'id', 'service_order', 'description', 'assigned_to',
            'status', 'estimated_time', 'actual_time',
            'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'service_order', 'created_at', 'updated_at')

    def validate(self, attrs):
        assigned_to = attrs.get('assigned_to')
        service_order = self.context['service_order']

        # Sprawdzenie, czy pracownik (jeśli podany) należy do warsztatu
        if assigned_to and assigned_to.workshop != service_order.workshop:
            raise serializers.ValidationError("Pracownik nie należy do tego warsztatu.")

        return attrs

    def create(self, validated_data):
        service_order = self.context['service_order']
        return ServiceTask.objects.create(service_order=service_order, **validated_data)
