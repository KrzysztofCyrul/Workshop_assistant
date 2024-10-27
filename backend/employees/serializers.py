from rest_framework import serializers
from accounts.models import Role, User
from workshops.models import Branch
from employees.models import Employee, ScheduleEntry
from accounts.serializers import UserSerializer
from workshops.serializers import BranchSerializer

class ScheduleEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = ScheduleEntry
        fields = (
            'id', 'employee', 'start_time', 'end_time',
            'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'created_at', 'updated_at', 'employee')
        
class EmployeeSerializer(serializers.ModelSerializer):
    user = serializers.PrimaryKeyRelatedField(queryset=User.objects.all())
    branch = serializers.PrimaryKeyRelatedField(queryset=Branch.objects.all(), required=False, allow_null=True)
    roles = serializers.PrimaryKeyRelatedField(many=True, queryset=Role.objects.all(), required=False)
    schedule_entries = ScheduleEntrySerializer(many=True, read_only=True)

    class Meta:
        model = Employee
        fields = (
            'id', 'user', 'workshop', 'branch', 'position',
            'hire_date', 'salary', 'roles', 'schedule_entries',
            'created_at', 'updated_at'
        )
        read_only_fields = ('id', 'created_at', 'updated_at', 'workshop', 'schedule_entries')

    def create(self, validated_data):
        workshop = self.context['workshop']
        roles_data = validated_data.pop('roles', [])
        user = validated_data['user']

        if not User.objects.filter(id=user.id).exists():
            raise serializers.ValidationError("Wybrany użytkownik nie istnieje.")

        if Employee.objects.filter(user=user, workshop=workshop).exists():
            raise serializers.ValidationError("Ten użytkownik jest już pracownikiem tego warsztatu.")

        branch = validated_data.get('branch')
        if branch and branch.workshop != workshop:
            raise serializers.ValidationError("Wybrany oddział nie należy do tego warsztatu.")

        employee = Employee.objects.create(workshop=workshop, **validated_data)
        employee.roles.set(roles_data)
        return employee
