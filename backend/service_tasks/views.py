from rest_framework import viewsets, permissions
from service_tasks.models import ServiceTask
from service_tasks.serializers import ServiceTaskSerializer
from service_orders.models import ServiceOrder
from workshops.models import Workshop
from accounts.permissions import IsWorkshopOwner, IsAdmin
from rest_framework.exceptions import PermissionDenied
from rest_framework.permissions import IsAuthenticated

class ServiceTaskViewSet(viewsets.ModelViewSet):
    serializer_class = ServiceTaskSerializer
    permission_classes = [IsAuthenticated, IsWorkshopOwner | IsAdmin]

    def get_queryset(self):
        workshop_id = self.kwargs['workshop_pk']
        order_id = self.kwargs['order_pk']
        return ServiceTask.objects.filter(service_order__id=order_id, service_order__workshop__id=workshop_id)

    def get_serializer_context(self):
        context = super().get_serializer_context()
        workshop_id = self.kwargs['workshop_pk']
        order_id = self.kwargs['order_pk']
        try:
            service_order = ServiceOrder.objects.get(id=order_id, workshop__id=workshop_id)
        except ServiceOrder.DoesNotExist:
            raise PermissionDenied("Nie znaleziono zlecenia lub brak dostępu do tego zlecenia.")
        context['service_order'] = service_order
        return context

    def perform_create(self, serializer):
        service_order = self.get_serializer_context()['service_order']
        serializer.save(service_order=service_order)
