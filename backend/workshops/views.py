from rest_framework import viewsets
from workshops.models import Workshop
from workshops.serializers import WorkshopSerializer
from rest_framework.permissions import IsAuthenticated
from accounts.permissions import IsMechanic, IsWorkshopOwner, IsAdmin, IsClient
from django.utils.timezone import now


class WorkshopViewSet(viewsets.ModelViewSet):
    serializer_class = WorkshopSerializer
    permission_classes = [IsAuthenticated, IsMechanic | IsWorkshopOwner | IsAdmin | IsClient]

    def get_queryset(self):
        user = self.request.user

        if user.is_superuser:
            return Workshop.objects.all()

        if user.roles.filter(name='workshop_owner').exists():
            return Workshop.objects.filter(owner=user)

        if user.roles.filter(name='mechanic').exists():
            assigned_workshops = Workshop.objects.filter(employees__user=user).distinct()
            if not assigned_workshops.exists():
                return Workshop.objects.all()
            return assigned_workshops

        if user.roles.filter(name='client').exists():
            return Workshop.objects.filter(reservations__client=user).distinct()

        return Workshop.objects.none()

    def perform_create(self, serializer):
        workshop = serializer.save(owner=self.request.user)
        
        # Add the owner as an employee of the workshop
        from employees.models import Employee  # Import your Employee model
        Employee.objects.create(
            user=self.request.user,
            workshop=workshop,
            position='workshop_owner',  # Or any default position for owners
            status='APPROVED',  # Set default status
            hire_date=now(),
        )