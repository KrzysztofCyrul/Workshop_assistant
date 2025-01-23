from pyexpat.errors import messages
from django.shortcuts import get_object_or_404, redirect
from rest_framework import viewsets, permissions
from appointments.models import Appointment, RepairItem, Part
from appointments.serializers import AppointmentSerializer, PartSerializer, RepairItemSerializer
# from ai_module.signals import get_appointment_recommendations
from workshops.models import Workshop
from accounts.permissions import IsMechanic, IsWorkshopOwner, IsAdmin
from rest_framework.exceptions import PermissionDenied
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status, views
from rest_framework.exceptions import ValidationError


class AppointmentViewSet(viewsets.ModelViewSet):
    serializer_class = AppointmentSerializer
    permission_classes = [IsAuthenticated, IsWorkshopOwner | IsAdmin | IsMechanic]

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
    
    def partial_update(self, request, *args, **kwargs):
        kwargs['partial'] = True
        return super().partial_update(request, *args, **kwargs)
    
    def get_permissions(self):
        if self.action in ['update', 'patch' 'partial_update', 'destroy']:
            permission_classes = [permissions.IsAuthenticated, IsWorkshopOwner | IsAdmin]
        else:
            permission_classes = [permissions.IsAuthenticated]
        return [permission() for permission in permission_classes]
    
class RepairItemViewSet(viewsets.ModelViewSet):
    serializer_class = RepairItemSerializer
    permission_classes = [IsAuthenticated, IsWorkshopOwner | IsAdmin | IsMechanic] 

    def get_queryset(self):
        workshop_id = self.kwargs['workshop_pk']
        appointment_id = self.kwargs['appointment_pk']
        return RepairItem.objects.filter(
            appointment__id=appointment_id,
            appointment__workshop__id=workshop_id
        )

    def get_serializer_context(self):
        context = super().get_serializer_context()
        workshop_id = self.kwargs['workshop_pk']
        appointment_id = self.kwargs['appointment_pk']
        try:
            appointment = Appointment.objects.get(id=appointment_id, workshop__id=workshop_id)
        except Appointment.DoesNotExist:
            raise PermissionDenied("Nie znaleziono wizyty lub brak dostępu do tej wizyty.")
        context['appointment'] = appointment
        return context

    def perform_create(self, serializer):
        serializer.save()

    def partial_update(self, request, *args, **kwargs):
        kwargs['partial'] = True
        return self.update(request, *args, **kwargs)

    def get_permissions(self):
        if self.action in ['patch','update', 'partial_update', 'destroy']:
            permission_classes = [IsAuthenticated, IsWorkshopOwner | IsAdmin | IsMechanic]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]
        
class GenerateRecommendationsAPIView(views.APIView):
    permission_classes = [IsAuthenticated, IsWorkshopOwner | IsAdmin | IsMechanic] 

    def post(self, request, appointment_id):
        appointment = get_object_or_404(Appointment, id=appointment_id)
        repair_items = appointment.repair_items.all()
        appointment_description = appointment.notes or "Brak opisu wizyty."

        if not repair_items:
            return Response(
                {"detail": "Wizyta nie ma przypisanych żadnych prac do wykonania."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # recommendations = get_appointment_recommendations(appointment_description, repair_items)

        # if recommendations:
        #     appointment.recommendations = recommendations
        #     appointment.save()
        #     serializer = AppointmentSerializer(appointment)
        #     return Response(serializer.data, status=status.HTTP_200_OK)
        # else:
        #     return Response(
        #         {"detail": "Nie udało się wygenerować rekomendacji."},
        #         status=status.HTTP_500_INTERNAL_SERVER_ERROR
        #     )
        
class PartViewSet(viewsets.ModelViewSet):
    serializer_class = PartSerializer
    permission_classes = [IsAuthenticated, IsWorkshopOwner | IsAdmin | IsMechanic]

    def get_queryset(self):
        workshop_id = self.kwargs['workshop_pk']
        appointment_id = self.kwargs['appointment_pk']
        return Part.objects.filter(
            appointment__id=appointment_id,
            appointment__workshop__id=workshop_id
        )

    def get_serializer_context(self):
        context = super().get_serializer_context()
        workshop_id = self.kwargs['workshop_pk']
        appointment_id = self.kwargs['appointment_pk']
        try:
            appointment = Appointment.objects.get(id=appointment_id, workshop__id=workshop_id)
        except Appointment.DoesNotExist:
            raise PermissionDenied("Nie znaleziono wizyty lub brak dostępu do tej wizyty.")
        context['appointment'] = appointment
        return context

    def perform_create(self, serializer):
        appointment = self.get_serializer_context()['appointment']
        try:
            serializer.save(appointment=appointment)
        except ValidationError as e:
            print(f"Błąd walidacji: {e.detail}")
            raise e
        print(f"Część zapisana: {serializer.data}")
