from django.utils import timezone
import random
from django.shortcuts import get_object_or_404
from rest_framework import viewsets, permissions, generics, status
from rest_framework.views import APIView
from accounts.models import Role
from employees.models import Employee, ScheduleEntry, TemporaryCode
from employees.serializers import EmployeeSerializer, EmployeeStatusUpdateSerializer, ScheduleEntrySerializer, EmployeeAssignmentSerializer
from workshops.models import Workshop
from rest_framework.exceptions import PermissionDenied
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from accounts.permissions import IsWorkshopOwner, IsAdmin, IsMechanic


class EmployeeViewSet(viewsets.ModelViewSet):
    serializer_class = EmployeeSerializer
    permission_classes = [IsAuthenticated, IsWorkshopOwner | IsAdmin | IsMechanic]
    
    def get_queryset(self):
        workshop_id = self.kwargs['workshop_pk']
        workshop = Workshop.objects.get(id=workshop_id)
        return Employee.objects.filter(workshop=workshop)

    
    def get_serializer_context(self):
        context = super().get_serializer_context()
        if not getattr(self, 'swagger_fake_view', False):
            workshop_id = self.kwargs['workshop_pk']
            context['workshop_id'] = workshop_id
        return context
    
    def perform_create(self, serializer):
        workshop = self.get_serializer_context()['workshop']
        user = self.request.user
        if user.is_superuser or workshop.owner == user:
            serializer.save()
        else:
            raise PermissionDenied("Nie masz uprawnień do dodawania pracowników do tego warsztatu.")
        
class EmployeeAssignRoleView(generics.CreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = EmployeeSerializer 
    
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
    permission_classes = [IsAuthenticated]
    
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
    permission_classes = [IsAuthenticated]
    
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
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        employee_id = self.kwargs['employee_pk']
        workshop_id = self.kwargs['workshop_pk']
        employee = Employee.objects.get(id=employee_id, workshop__id=workshop_id)
        if self.request.user.is_superuser or employee.workshop.owner == self.request.user:
            return ScheduleEntry.objects.filter(employee=employee)
        else:
            raise PermissionDenied("Nie masz uprawnień do modyfikowania harmonogramu tego pracownika.")
        
class RequestAssignmentView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, workshop_id):
        # Pobierz warsztat na podstawie ID lub zwróć 404
        workshop = get_object_or_404(Workshop, id=workshop_id)

        # Sprawdź, czy użytkownik już wysłał prośbę lub jest przypisany
        if Employee.objects.filter(user=request.user, workshop=workshop).exists():
            return Response(
                {"detail": "You have already sent a request or are assigned to this workshop."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Serializacja danych
        serializer = EmployeeAssignmentSerializer(
            data=request.data,
            context={'user': request.user, 'workshop': workshop}
        )
        
        # Walidacja i zapis
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        
        # Błędy walidacji
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ApproveAssignmentView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, employee_id):
        employee = get_object_or_404(Employee, id=employee_id)
        if employee.workshop.owner != request.user:
            return Response({"detail": "Not authorized"}, status=status.HTTP_403_FORBIDDEN)
        
        serializer = EmployeeStatusUpdateSerializer(employee, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class PendingAssignmentListView(generics.ListAPIView):
    serializer_class = EmployeeAssignmentSerializer
    permission_classes = [IsAuthenticated, IsWorkshopOwner]

    def get_queryset(self):
        workshop_id = self.kwargs['workshop_id']
        workshop = get_object_or_404(Workshop, id=workshop_id, owner=self.request.user)
        
        return Employee.objects.filter(workshop=workshop, status='PENDING')


class GenerateTemporaryCodeView(APIView):
    permission_classes = [IsAuthenticated, IsWorkshopOwner]

    def post(self, request, workshop_id):
        workshop = get_object_or_404(Workshop, id=workshop_id)
        if workshop.owner != request.user:
            return Response({"detail": "Not authorized"}, status=status.HTTP_403_FORBIDDEN)

        # Generowanie 6-cyfrowego kodu
        code = str(random.randint(100000, 999999))  # Generate a random 6-digit code
        expires_at = timezone.now() + timezone.timedelta(minutes=15)

        temporary_code = TemporaryCode.objects.create(
            code=code,
            workshop=workshop,
            created_by=request.user,
            expires_at=expires_at
        )

        return Response({"code": code, "expires_at": expires_at}, status=status.HTTP_201_CREATED)
    
class UseTemporaryCodeView(APIView):
    permission_classes = [IsAuthenticated, IsMechanic]

    def post(self, request):
        code = request.data.get('code')
        if not code:
            return Response({"detail": "Code is required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            temporary_code = TemporaryCode.objects.get(code=code)
        except TemporaryCode.DoesNotExist:
            return Response({"detail": "Invalid code"}, status=status.HTTP_404_NOT_FOUND)

        if not temporary_code.is_valid():
            return Response({"detail": "Code has expired"}, status=status.HTTP_400_BAD_REQUEST)

        # Sprawdź, czy użytkownik już jest przypisany do warsztatu
        if Employee.objects.filter(user=request.user, workshop=temporary_code.workshop).exists():
            return Response({"detail": "You are already assigned to this workshop"}, status=status.HTTP_400_BAD_REQUEST)

        # Dodanie mechanika do warsztatu
        Employee.objects.create(
            user=request.user,
            workshop=temporary_code.workshop,
            position="Mechanic",
            status='APPROVED',
            hire_date=timezone.now()
        )

        # Usunięcie kodu po użyciu
        temporary_code.delete()

        return Response({"detail": "You have been successfully added to the workshop"}, status=status.HTTP_200_OK)