from rest_framework import viewsets, permissions, generics
from workshops.models import Branch, Workshop
from workshops.serializers import BranchSerializer, WorkshopSerializer
from rest_framework.exceptions import PermissionDenied
from accounts.permissions import IsMechanic, IsWorkshopOwner, IsAdmin, IsClient
from rest_framework.permissions import IsAuthenticated, AllowAny

class WorkshopViewSet(viewsets.ModelViewSet):
    serializer_class = WorkshopSerializer
    permission_classes = [IsAuthenticated, IsWorkshopOwner | IsAdmin]

    def get_queryset(self):
        user = self.request.user
        if user.is_superuser:
            return Workshop.objects.all()
        else:
            return Workshop.objects.filter(owner=user)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)
        
class BranchListCreateView(generics.ListCreateAPIView):
    serializer_class = BranchSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        workshop_id = self.kwargs['workshop_pk']
        return Branch.objects.filter(workshop__id=workshop_id, workshop__owner=self.request.user)

    def perform_create(self, serializer):
        workshop_id = self.kwargs['workshop_pk']
        try:
            workshop = Workshop.objects.get(id=workshop_id, owner=self.request.user)
        except Workshop.DoesNotExist:
            raise PermissionDenied("Nie masz uprawnień do tego warsztatu.")
        serializer.save(workshop=workshop)

class BranchDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = BranchSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        workshop_id = self.kwargs['workshop_pk']
        return Branch.objects.filter(workshop__id=workshop_id, workshop__owner=self.request.user)
