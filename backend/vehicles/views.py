from rest_framework import viewsets, permissions
from vehicles.models import Vehicle
from vehicles.serializers import VehicleSerializer
from clients.models import Client
from workshops.models import Workshop
from accounts.permissions import IsWorkshopOwner, IsAdmin
from rest_framework.exceptions import PermissionDenied
from rest_framework.permissions import IsAuthenticated


class VehicleViewSet(viewsets.ModelViewSet):
    serializer_class = VehicleSerializer
    permission_classes = [IsAuthenticated, IsWorkshopOwner | IsAdmin]

    def get_queryset(self):
        workshop_id = self.kwargs.get('workshop_pk')
        client_id = self.kwargs.get('client_pk')
        vehicle_id = self.kwargs.get('pk')

        if not Workshop.objects.filter(id=workshop_id, owner=self.request.user).exists() and not self.request.user.is_superuser:
            raise PermissionDenied("Nie masz dostępu do tego warsztatu.")

        if client_id:
            return Vehicle.objects.filter(client__id=client_id, client__workshop__id=workshop_id)
        elif vehicle_id:
            return Vehicle.objects.filter(id=vehicle_id, client__workshop__id=workshop_id)
        else:
            return Vehicle.objects.none()


    def perform_create(self, serializer):
        workshop_id = self.kwargs.get('workshop_pk')
        client_id = self.kwargs.get('client_pk')

        try:
            client = Client.objects.get(id=client_id, workshop__id=workshop_id)
        except Client.DoesNotExist:
            raise PermissionDenied("Nie znaleziono klienta lub brak dostępu do tego klienta.")

        serializer.save(client=client)
