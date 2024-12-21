from rest_framework import serializers
from vehicles.models import Vehicle

class VehicleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vehicle
        fields = (
            'id', 'client', 'make', 'model', 'year',
            'vin', 'engine_type', 'license_plate', 'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'client', 'created_at', 'updated_at')

