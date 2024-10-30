from django.contrib import admin
from django.urls import path, include, re_path
from .views import MyTokenObtainPairView, MyTokenRefreshView
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView
from rest_framework.permissions import AllowAny



urlpatterns = [
        # Endpoint do schematu
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    
    # Endpoint do Swagger UI
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),

    # (Opcjonalnie) Endpoint do Redoc
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
 
    path('admin/', admin.site.urls),
    path('api/', include([
        path('', include('accounts.urls')),
        path('', include('workshops.urls')),
        path('', include('employees.urls')),
        path('', include('clients.urls')),
        path('', include('vehicles.urls')),
        path('', include('service_records.urls')),
        path('', include('appointments.urls')),
        path('token/', MyTokenObtainPairView.as_view(), name='token_obtain_pair'),
        path('token/refresh/', MyTokenRefreshView.as_view(), name='token_refresh'),
    ])),
]