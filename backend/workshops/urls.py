from django.urls import path, include
from rest_framework.routers import DefaultRouter
from workshops.views import WorkshopViewSet, BranchListCreateView, BranchDetailView

router = DefaultRouter()
router.register(r'workshops', WorkshopViewSet, basename='workshop')

urlpatterns = [
    path('', include(router.urls)),
    path('workshops/<uuid:workshop_pk>/branches/', BranchListCreateView.as_view(), name='branch-list-create'),
    path('workshops/<uuid:workshop_pk>/branches/<uuid:pk>/', BranchDetailView.as_view(), name='branch-detail'),
]
