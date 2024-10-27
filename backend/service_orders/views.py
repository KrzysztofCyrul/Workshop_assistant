from rest_framework import viewsets, permissions
from service_orders.models import ServiceOrder
from service_orders.serializers import ServiceOrderSerializer
from workshops.models import Workshop
from accounts.permissions import IsWorkshopOwner, IsAdmin
from rest_framework.exceptions import PermissionDenied
from rest_framework.permissions import IsAuthenticated

class ServiceOrderViewSet(viewsets.ModelViewSet):
    serializer_class = ServiceOrderSerializer
    permission_classes = [IsAuthenticated, IsWorkshopOwner | IsAdmin]

    def get_queryset(self):
        workshop_id = self.kwargs['workshop_pk']
        return ServiceOrder.objects.filter(workshop__id=workshop_id)

    def get_serializer_context(self):
        context = super().get_serializer_context()
        workshop_id = self.kwargs['workshop_pk']
        context['workshop'] = Workshop.objects.get(id=workshop_id)
        return context

    def perform_create(self, serializer):
        workshop = self.get_serializer_context()['workshop']
        serializer.save(workshop=workshop)
