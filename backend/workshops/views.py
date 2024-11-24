from rest_framework import viewsets, permissions, generics
from workshops.models import Workshop
from workshops.serializers import  WorkshopSerializer
from rest_framework.exceptions import PermissionDenied
from accounts.permissions import IsMechanic, IsWorkshopOwner, IsAdmin, IsClient
from rest_framework.permissions import IsAuthenticated, AllowAny

class WorkshopViewSet(viewsets.ModelViewSet):
    serializer_class = WorkshopSerializer
    permission_classes = [IsAuthenticated, IsMechanic | IsWorkshopOwner | IsAdmin | IsClient]

    def get_queryset(self):
        user = self.request.user

        # Admin widzi wszystkie warsztaty
        if user.is_superuser:
            return Workshop.objects.all()

        # Workshop Owner widzi tylko swoje warsztaty
        if user.roles.filter(name='workshop_owner').exists():
            return Workshop.objects.filter(owner=user)

        # Mechanic widzi warsztaty, w których jest przypisany jako mechanik,
        # lub wszystkie warsztaty, jeśli nie jest przypisany do żadnego
        if user.roles.filter(name='mechanic').exists():
            assigned_workshops = Workshop.objects.filter(employees__user=user).distinct()
            if not assigned_workshops.exists():
                # Mechanik bez przypisania widzi wszystkie warsztaty
                return Workshop.objects.all()

            # Mechanik przypisany widzi swoje warsztaty
            return assigned_workshops

        # Client widzi warsztaty, w których ma aktywne rezerwacje (jeśli jest taki mechanizm)
        if user.roles.filter(name='client').exists():
            return Workshop.objects.filter(reservations__client=user).distinct()

        # W przypadku braku odpowiedniej roli, zwracamy puste queryset
        return Workshop.objects.none()

