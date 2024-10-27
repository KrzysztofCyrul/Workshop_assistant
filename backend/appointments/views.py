from rest_framework import viewsets, permissions
from appointments.models import Appointment
from appointments.serializers import AppointmentSerializer
from workshops.models import Workshop
from accounts.permissions import IsWorkshopOwner, IsAdmin
from rest_framework.exceptions import PermissionDenied

class AppointmentViewSet(viewsets.ModelViewSet):
    serializer_class = AppointmentSerializer
    permission_classes = [permissions.IsAuthenticated, IsWorkshopOwner | IsAdmin]

    def get_queryset(self):
        workshop_id = self.kwargs['workshop_pk']
        return Appointment.objects.filter(workshop__id=workshop_id)

    def get_serializer_context(self):
        context = super().get_serializer_context()
        workshop_id = self.kwargs['workshop_pk']
        context['workshop'] = Workshop.objects.get(id=workshop_id)
        return context

    def perform_create(self, serializer):
        workshop = self.get_serializer_context()['workshop']
        serializer.save(workshop=workshop)

    def destroy(self, request, *args, **kwargs):
        appointment = self.get_object()
        appointment.status = 'canceled'
        appointment.save()
        return Response({"detail": "Wizyta została anulowana."}, status=status.HTTP_200_OK)
    
    def get_permissions(self):
        if self.action in ['update', 'partial_update', 'destroy']:
            permission_classes = [permissions.IsAuthenticated, IsWorkshopOwner | IsAdmin]
        else:
            permission_classes = [permissions.IsAuthenticated]
        return [permission() for permission in permission_classes]