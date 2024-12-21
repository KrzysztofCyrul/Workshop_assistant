from django.utils import timezone
from rest_framework import serializers
from accounts.models import Role, User
from employees.models import Employee, ScheduleEntry

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
    roles = serializers.PrimaryKeyRelatedField(many=True, queryset=Role.objects.all(), required=False)
    schedule_entries = ScheduleEntrySerializer(many=True, read_only=True)
    user_full_name = serializers.SerializerMethodField()
    workshop_name = serializers.CharField(source='workshop.name', read_only=True)


    class Meta:
        model = Employee
        fields = (
            'id', 'user', 'user_full_name','workshop', 'workshop_name', 'position',
            'hire_date', 'salary', 'roles', 'schedule_entries',
            'created_at', 'updated_at', 'status'
        )
        read_only_fields = ('id', 'created_at', 'updated_at', 'workshop', 'schedule_entries')
        
    def get_user_full_name(self, obj):
        return f"{obj.user.first_name} {obj.user.last_name}"

    def create(self, validated_data):
        workshop = self.context['workshop']
        roles_data = validated_data.pop('roles', [])
        user = validated_data['user']

        if not User.objects.filter(id=user.id).exists():
            raise serializers.ValidationError("Wybrany użytkownik nie istnieje.")

        if Employee.objects.filter(user=user, workshop=workshop).exists():
            raise serializers.ValidationError("Ten użytkownik jest już pracownikiem tego warsztatu.")

        employee = Employee.objects.create(workshop=workshop, **validated_data)
        employee.roles.set(roles_data)
        return employee
    
class EmployeeAssignmentSerializer(serializers.ModelSerializer):
    user_full_name = serializers.CharField(source='user.get_full_name', read_only=True)

    class Meta:
        model = Employee
        fields = ['id', 'user_full_name', 'status']

    def create(self, validated_data):
        user = self.context['user']
        workshop = self.context['workshop']

        # Domyślna data zatrudnienia z aktualną datą i godziną
        hire_date = timezone.now()

        # Sprawdzenie, czy użytkownik już wysłał prośbę
        if Employee.objects.filter(user=user, workshop=workshop).exists():
            raise serializers.ValidationError(
                {"detail": "You have already sent a request or are assigned to this workshop."}
            )

        # Tworzenie prośby z domyślnym stanowiskiem i datą
        return Employee.objects.create(
            user=user,
            workshop=workshop,
            hire_date=hire_date,  # Ustawiamy aktualną datę i godzinę
            position="Mechanik",  # Ustawiamy domyślne stanowisko
            status='PENDING',  # Ustawiamy domyślny status
            **validated_data
        )

    def validate(self, attrs):
        user = self.context['user']
        workshop = self.context['workshop']

        # Sprawdzanie konfliktów
        if Employee.objects.filter(user=user, workshop=workshop).exists():
            raise serializers.ValidationError(
                {"detail": "You are already assigned or have a pending request for this workshop."}
            )
        return attrs
    
class EmployeeStatusUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Employee
        fields = ['status']
