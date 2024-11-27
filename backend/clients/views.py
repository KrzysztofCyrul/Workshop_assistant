from rest_framework import viewsets, permissions
from clients.models import Client
from clients.serializers import ClientSerializer
from workshops.models import Workshop
from accounts.permissions import IsWorkshopOwner, IsAdmin, IsMechanic
from rest_framework.permissions import IsAuthenticated

class ClientViewSet(viewsets.ModelViewSet):
    serializer_class = ClientSerializer
    permission_classes = [IsAuthenticated, IsWorkshopOwner | IsMechanic | IsAdmin]

    def get_queryset(self):
        workshop_id = self.kwargs['workshop_pk']
        return Client.objects.filter(workshop__id=workshop_id)

    def perform_create(self, serializer):
        workshop_id = self.kwargs['workshop_pk']
        workshop = Workshop.objects.get(id=workshop_id)
        serializer.save(workshop=workshop)
