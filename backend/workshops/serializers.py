from rest_framework import serializers
from workshops.models import Workshop
class WorkshopSerializer(serializers.ModelSerializer):


    class Meta:
        model = Workshop
        fields = (
            'id','owner', 'name', 'address', 'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'created_at', 'updated_at')
