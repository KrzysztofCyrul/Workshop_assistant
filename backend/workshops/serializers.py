from rest_framework import serializers
from workshops.models import Workshop, Branch

class BranchSerializer(serializers.ModelSerializer):
    class Meta:
        model = Branch
        fields = (
            'id', 'name', 'address', 'phone', 'email',
            'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'created_at', 'updated_at')

class WorkshopSerializer(serializers.ModelSerializer):
    branches = BranchSerializer(many=True)

    class Meta:
        model = Workshop
        fields = (
            'id', 'name', 'address', 'created_at', 'updated_at', 'branches'
        )
        read_only_fields = ('id', 'created_at', 'updated_at', 'branches')
