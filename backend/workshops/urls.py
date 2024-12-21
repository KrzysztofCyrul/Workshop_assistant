from django.urls import path, include
from rest_framework.routers import DefaultRouter
from workshops.views import WorkshopViewSet
from emailer.views import EmailSettingsView

router = DefaultRouter()
router.register(r'workshops', WorkshopViewSet, basename='workshop')

urlpatterns = [
    path('', include(router.urls)),
]
