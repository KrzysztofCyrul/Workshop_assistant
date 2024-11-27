from rest_framework import serializers
from clients.models import Client

class ClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Client
        fields = (
            'id', 'workshop', 'first_name', 'last_name', 'email',
            'phone', 'address','segment', 'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'workshop', 'created_at', 'updated_at')
