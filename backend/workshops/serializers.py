from rest_framework import serializers
from workshops.models import Workshop

class WorkshopSerializer(serializers.ModelSerializer):
    phone_number = serializers.CharField(source='phone', allow_blank=True, allow_null=True, required=False)
    
    class Meta:
        model = Workshop
        fields = ['id', 'name', 'address', 'post_code', 'nip_number', 'email', 'phone_number']
        read_only_fields = ['id']
        
    def create(self, validated_data):
        return super().create(validated_data)
        
    def update(self, instance, validated_data):
        return super().update(instance, validated_data)