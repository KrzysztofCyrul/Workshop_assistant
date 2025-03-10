from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.exceptions import PermissionDenied, ValidationError
from .models import Quotation, QuotationPart
from .serializers import QuotationSerializer, QuotationPartSerializer
from workshops.models import Workshop
from accounts.permissions import IsWorkshopOwner, IsAdmin, IsMechanic
from rest_framework.permissions import IsAuthenticated

class QuotationViewSet(viewsets.ModelViewSet):
    serializer_class = QuotationSerializer
    permission_classes = [IsAuthenticated, IsWorkshopOwner | IsAdmin | IsMechanic]

    def get_queryset(self):
        workshop_id = self.kwargs['workshop_pk']
        return Quotation.objects.filter(workshop__id=workshop_id)

    def get_serializer_context(self):
        context = super().get_serializer_context()
        workshop_id = self.kwargs['workshop_pk']
        context['workshop'] = Workshop.objects.get(id=workshop_id)
        return context

    def perform_create(self, serializer):
        workshop = self.get_serializer_context()['workshop']
        serializer.save(workshop=workshop)

    def destroy(self, request, *args, **kwargs):
        quotation = self.get_object()
        quotation.delete()
        return Response({"detail": "Wycenę usunięto pomyślnie."}, status=status.HTTP_204_NO_CONTENT)

    def partial_update(self, request, *args, **kwargs):
        kwargs['partial'] = True
        return super().partial_update(request, *args, **kwargs)

    def get_permissions(self):
        if self.action in ['update', 'partial_update', 'destroy']:
            permission_classes = [IsAuthenticated, IsWorkshopOwner | IsAdmin]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]


class QuotationPartViewSet(viewsets.ModelViewSet):
    serializer_class = QuotationPartSerializer
    permission_classes = [IsAuthenticated, IsWorkshopOwner | IsAdmin | IsMechanic]

    def get_queryset(self):
        workshop_id = self.kwargs['workshop_pk']
        quotation_id = self.kwargs['quotation_pk']
        return QuotationPart.objects.filter(
            quotation__id=quotation_id,
            quotation__workshop__id=workshop_id
        )

    def get_serializer_context(self):
        context = super().get_serializer_context()
        workshop_id = self.kwargs['workshop_pk']
        quotation_id = self.kwargs['quotation_pk']
        try:
            quotation = Quotation.objects.get(id=quotation_id, workshop__id=workshop_id)
        except Quotation.DoesNotExist:
            raise PermissionDenied("Nie znaleziono wyceny lub brak dostępu do tej wyceny.")
        context['quotation'] = quotation
        return context

    def perform_create(self, serializer):
        quotation = self.get_serializer_context()['quotation']
        serializer.save(quotation=quotation)

    def partial_update(self, request, *args, **kwargs):
        kwargs['partial'] = True
        return self.update(request, *args, **kwargs)

    def get_permissions(self):
        if self.action in ['patch', 'update', 'partial_update', 'destroy']:
            permission_classes = [IsAuthenticated, IsWorkshopOwner | IsAdmin | IsMechanic]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]