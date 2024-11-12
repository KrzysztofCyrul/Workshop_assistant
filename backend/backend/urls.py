from django.contrib import admin
from django.urls import path, include, re_path
from .views import MyTokenObtainPairView, MyTokenRefreshView
from drf_yasg import openapi
from drf_yasg.views import get_schema_view
from rest_framework.permissions import AllowAny


schema_view = get_schema_view(
    openapi.Info(
        title="API Dokumentacja",
        default_version='v1',
        description="Opis API",
    ),
    public=True,
    permission_classes=(AllowAny,),
)


urlpatterns = [
    re_path(r'^swagger(?P<format>\.json|\.yaml)$', schema_view.without_ui(cache_timeout=0), name='schema-json'),
    path('swagger/', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    path('redoc/', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),

 
    path('admin/', admin.site.urls),
    path('api/', include([
        path('', include('ai_module.urls')),
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