from django.db.models.signals import post_save
from django.dispatch import receiver
from accounts.models import User

@receiver(post_save, sender=User)
def user_post_save(sender, instance, created, **kwargs):
    if created:
        # Dodatkowe działania po utworzeniu użytkownika
        print(f'Utworzono nowego użytkownika: {instance.email}')
