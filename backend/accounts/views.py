from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import authenticate, login, logout
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework import viewsets
from .models import Permission, Role, User
from .serializers import PermissionSerializer, RoleSerializer, UserProfileSerializer, UserSerializer
from rest_framework_simplejwt.tokens import RefreshToken
from .permissions import IsMechanic, IsWorkshopOwner, IsAdmin, IsClient

class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')
        first_name = request.data.get('first_name')
        last_name = request.data.get('last_name')
        role_name = request.data.get('role')
        
        errors = {}

        if not email:
            errors['email'] = 'Email jest wymagany.'
        elif User.objects.filter(email=email).exists():
            errors['email'] = 'Użytkownik z podanym adresem email już istnieje.'

        if not password:
            errors['password'] = 'Hasło jest wymagane.'
        elif len(password) < 8:
            errors['password'] = 'Hasło musi mieć co najmniej 8 znaków.'

        if not first_name:
            errors['first_name'] = 'Imię jest wymagane.'

        if not last_name:
            errors['last_name'] = 'Nazwisko jest wymagane.'

        if role_name not in ['mechanic', 'workshop_owner', 'client']:
            errors['role'] = 'Nieprawidłowa rola. Wybierz mechanic, workshop_owner lub client.'
        else:
            try:
                role = Role.objects.get(name=role_name)
            except Role.DoesNotExist:
                errors['role'] = 'Wybrana rola nie istnieje w bazie danych.'

        if errors:
            return Response({'errors': errors}, status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.create_user(
            email=email,
            password=password,
            first_name=first_name,
            last_name=last_name
        )

        user.roles.add(role)
        user.save()

        refresh = RefreshToken.for_user(user)

        return Response({
            'status': 'Użytkownik zarejestrowany pomyślnie',
            'access': str(refresh.access_token),
            'refresh': str(refresh)
        }, status=status.HTTP_201_CREATED)

class LoginView(APIView):
    permission_classes = [AllowAny]
    
    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')
        user = authenticate(request, email=email, password=password)
        
        if user is not None:
            refresh = RefreshToken.for_user(user)
            return Response({
                'status': 'Zalogowano pomyślnie',
                'access': str(refresh.access_token),
                'refresh': str(refresh)
            })
        else:
            return Response({'error': 'Nieprawidłowe dane uwierzytelniające'}, status=status.HTTP_400_BAD_REQUEST)

class LogoutView(APIView):
    def post(self, request):
        logout(request)
        return Response({'status': 'Wylogowano pomyślnie'})
    
   
class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
    
class RoleViewSet(viewsets.ModelViewSet):
    queryset = Role.objects.all()
    serializer_class = RoleSerializer
    permission_classes = [IsAuthenticated]
    
class PermissionViewSet(viewsets.ModelViewSet):
    queryset = Permission.objects.all()
    serializer_class = PermissionSerializer
    permission_classes = [IsAuthenticated]

class UserProfileView(APIView):
    permission_classes = [IsAuthenticated, IsMechanic | IsWorkshopOwner | IsAdmin | IsClient]

    def get(self, request):
        serializer = UserProfileSerializer(request.user)
        return Response(serializer.data)

    def put(self, request):
        self.permission_classes = [IsAuthenticated, IsAdmin | IsClient]
        
        if not self.check_permissions(request):
            return Response({"error": "Brak dostępu do edycji profilu"}, status=status.HTTP_403_FORBIDDEN)

        serializer = UserProfileSerializer(request.user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)