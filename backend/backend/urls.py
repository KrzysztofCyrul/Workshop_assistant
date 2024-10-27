from django.contrib import admin
from django.urls import path, include, re_path
from .views import MyTokenObtainPairView, MyTokenRefreshView

urlpatterns = [
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