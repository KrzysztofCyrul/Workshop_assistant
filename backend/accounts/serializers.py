from rest_framework import serializers
from accounts.models import Permission, User, Role
from employees.serializers import EmployeeSerializer

class UserSerializer(serializers.ModelSerializer):
    roles = serializers.PrimaryKeyRelatedField(many=True, queryset=Role.objects.all(), required=False)
    password_confirm = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = (
            'id', 'email', 'password', 'password_confirm', 'first_name', 'last_name',
            'is_active', 'created_at', 'updated_at', 'roles'
        )
        read_only_fields = ('created_at', 'updated_at', 'is_active')
        extra_kwargs = {'password': {'write_only': True}}

    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError({"password": "Hasła nie są takie same."})
        return data

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        password = validated_data.pop('password')
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        return user

    def update(self, instance, validated_data):
        roles_data = validated_data.pop('roles', None)
        password = validated_data.pop('password', None)
        validated_data.pop('password_confirm', None)

        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        if password:
            instance.set_password(password)
        instance.save()

        if roles_data is not None:
            instance.roles.set(roles_data)

        return instance
    
class UserProfileSerializer(serializers.ModelSerializer):
    roles = serializers.SerializerMethodField()
    employee_profiles = EmployeeSerializer(many=True, read_only=True)

    class Meta:
        model = User
        fields = ['id', 'email', 'first_name', 'last_name', 'roles', 'employee_profiles']

    def get_roles(self, obj):
        return list(obj.roles.values_list('name', flat=True))

    
class PermissionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Permission
        fields = ('id', 'name')    
        
class RoleSerializer(serializers.ModelSerializer):
    permissions = serializers.PrimaryKeyRelatedField(many=True, queryset=Permission.objects.all(), required=False)

    class Meta:
        model = Role
        fields = ('id', 'name', 'permissions')
        

