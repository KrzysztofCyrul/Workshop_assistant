from requests import Response
from rest_framework import viewsets, permissions, generics
from accounts.models import Role
from employees.models import Employee, ScheduleEntry
from employees.serializers import EmployeeSerializer, ScheduleEntrySerializer
from workshops.models import Workshop
from rest_framework.exceptions import PermissionDenied
from rest_framework.permissions import IsAuthenticated

class EmployeeViewSet(viewsets.ModelViewSet):
    serializer_class = EmployeeSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        workshop_id = self.kwargs['workshop_pk']
        workshop = Workshop.objects.get(id=workshop_id)
        user = self.request.user
        if user.is_superuser or workshop.owner == user:
            return Employee.objects.filter(workshop=workshop)
        else:
            raise PermissionDenied("Nie masz uprawnień do przeglądania pracowników tego warsztatu.")
    
    def get_serializer_context(self):
        context = super().get_serializer_context()
        workshop_id = self.kwargs['workshop_pk']
        workshop = Workshop.objects.get(id=workshop_id)
        context['workshop'] = workshop
        return context
    
    def perform_create(self, serializer):
        workshop = self.get_serializer_context()['workshop']
        user = self.request.user
        if user.is_superuser or workshop.owner == user:
            serializer.save()
        else:
            raise PermissionDenied("Nie masz uprawnień do dodawania pracowników do tego warsztatu.")
        
class EmployeeAssignRoleView(generics.CreateAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = EmployeeSerializer  # Możemy użyć specjalnego serializatora
    
    def post(self, request, *args, **kwargs):
        workshop_id = self.kwargs['workshop_pk']
        employee_id = self.kwargs['employee_pk']
        role_id = request.data.get('role_id')
        try:
            employee = Employee.objects.get(id=employee_id, workshop__id=workshop_id)
            role = Role.objects.get(id=role_id)
        except (Employee.DoesNotExist, Role.DoesNotExist):
            raise PermissionDenied("Nie znaleziono pracownika lub roli.")
        if request.user.is_superuser or employee.workshop.owner == request.user:
            employee.roles.add(role)
            return Response({"status": "Rola przypisana."})
        else:
            raise PermissionDenied("Nie masz uprawnień do przypisywania ról.")

class EmployeeRemoveRoleView(generics.DestroyAPIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def delete(self, request, *args, **kwargs):
        workshop_id = self.kwargs['workshop_pk']
        employee_id = self.kwargs['employee_pk']
        role_id = self.kwargs['role_pk']
        try:
            employee = Employee.objects.get(id=employee_id, workshop__id=workshop_id)
            role = Role.objects.get(id=role_id)
        except (Employee.DoesNotExist, Role.DoesNotExist):
            raise PermissionDenied("Nie znaleziono pracownika lub roli.")
        if request.user.is_superuser or employee.workshop.owner == request.user:
            employee.roles.remove(role)
            return Response({"status": "Rola usunięta."})
        else:
            raise PermissionDenied("Nie masz uprawnień do usuwania ról.")
        
class ScheduleEntryListCreateView(generics.ListCreateAPIView):
    serializer_class = ScheduleEntrySerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        employee_id = self.kwargs['employee_pk']
        workshop_id = self.kwargs['workshop_pk']
        employee = Employee.objects.get(id=employee_id, workshop__id=workshop_id)
        if self.request.user.is_superuser or employee.workshop.owner == self.request.user:
            return ScheduleEntry.objects.filter(employee=employee)
        else:
            raise PermissionDenied("Nie masz uprawnień do przeglądania harmonogramu tego pracownika.")
    
    def perform_create(self, serializer):
        employee_id = self.kwargs['employee_pk']
        workshop_id = self.kwargs['workshop_pk']
        employee = Employee.objects.get(id=employee_id, workshop__id=workshop_id)
        if self.request.user.is_superuser or employee.workshop.owner == self.request.user:
            serializer.save(employee=employee)
        else:
            raise PermissionDenied("Nie masz uprawnień do dodawania wpisów harmonogramu dla tego pracownika.")
        
class ScheduleEntryDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = ScheduleEntrySerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        employee_id = self.kwargs['employee_pk']
        workshop_id = self.kwargs['workshop_pk']
        employee = Employee.objects.get(id=employee_id, workshop__id=workshop_id)
        if self.request.user.is_superuser or employee.workshop.owner == self.request.user:
            return ScheduleEntry.objects.filter(employee=employee)
        else:
            raise PermissionDenied("Nie masz uprawnień do modyfikowania harmonogramu tego pracownika.")



