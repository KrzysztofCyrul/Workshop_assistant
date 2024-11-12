from celery import shared_task
from .ml_model import train_model

@shared_task
def train_model_task():
    train_model()