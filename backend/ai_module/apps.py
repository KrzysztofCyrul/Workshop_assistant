from django.apps import AppConfig


class AiModuleConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'ai_module'
    
    def ready(self):
        import ai_module.signals
