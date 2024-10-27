from rest_framework import serializers
from service_records.models import ServiceRecord

class ServiceRecordSerializer(serializers.ModelSerializer):
    appointment = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = ServiceRecord
        fields = (
            'id', 'vehicle', 'appointment', 'date', 'description', 'mileage',
            'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'vehicle', 'appointment', 'created_at', 'updated_at')