from rest_framework import generics, permissions
from service_records.models import ServiceRecord
from service_records.serializers import ServiceRecordSerializer
from vehicles.models import Vehicle
from clients.models import Client
from workshops.models import Workshop
from accounts.permissions import IsWorkshopOwner, IsAdmin, IsMechanic
from rest_framework.exceptions import PermissionDenied
from rest_framework.permissions import IsAuthenticated

class VehicleServiceHistoryView(generics.ListAPIView):
    serializer_class = ServiceRecordSerializer
    permission_classes = [IsAuthenticated, IsWorkshopOwner | IsAdmin | IsMechanic]

    def get_queryset(self):
        workshop_id = self.kwargs['workshop_pk']
        vehicle_id = self.kwargs['vehicle_pk']

        if not Workshop.objects.filter(id=workshop_id, owner=self.request.user).exists() and not self.request.user.is_superuser:
            raise PermissionDenied("Nie masz dostępu do tego warsztatu.")

        try:
            vehicle = Vehicle.objects.get(id=vehicle_id, client__workshop__id=workshop_id)
        except Vehicle.DoesNotExist:
            raise PermissionDenied("Nie znaleziono pojazdu lub brak dostępu do tego pojazdu.")

        return ServiceRecord.objects.filter(vehicle=vehicle)

class ClientServiceHistoryView(generics.ListAPIView):
    serializer_class = ServiceRecordSerializer
    permission_classes = [IsAuthenticated, IsWorkshopOwner | IsAdmin | IsMechanic]

    def get_queryset(self):
        workshop_id = self.kwargs['workshop_pk']
        client_id = self.kwargs['client_pk']

        if not Workshop.objects.filter(id=workshop_id, owner=self.request.user).exists() and not self.request.user.is_superuser:
            raise PermissionDenied("Nie masz dostępu do tego warsztatu.")

        try:
            client = Client.objects.get(id=client_id, workshop__id=workshop_id)
        except Client.DoesNotExist:
            raise PermissionDenied("Nie znaleziono klienta lub brak dostępu do tego klienta.")

        return ServiceRecord.objects.filter(vehicle__client=client)
