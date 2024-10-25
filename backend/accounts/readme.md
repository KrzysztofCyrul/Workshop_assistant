# User, Roles, and Permissions Management API

This Django project implements an API for managing users, roles, and permissions within a workshop-based system. It includes custom user management, role assignments, and permission handling to ensure only authenticated users have access to certain views.

## Features
- Custom user model based on Django's `AbstractBaseUser`.
- Role-based access control system.
- Permissions implemented with Django Rest Framework (DRF).
- JWT-based authentication (using `rest_framework_simplejwt`).
- Signals to handle additional actions after creating users.
- RESTful endpoints for CRUD operations on users, roles, and permissions.

## Requirements
- Django
- Django REST Framework (DRF)
- Django Simple JWT

## Models

### User
Custom user model that supports email-based authentication. Each user has the following fields:
- `id`: UUID
- `email`: Email address (used for authentication)
- `password`: Password
- `first_name` and `last_name`: User's name
- `roles`: Many-to-many relation with `Role`
- Other standard fields (`is_active`, `is_staff`, `created_at`, etc.)

### Role
Represents a role assigned to users. Each role can have multiple permissions.
- `id`: UUID
- `name`: Role name (e.g., mechanic, workshop owner, admin)
- `permissions`: Many-to-many relation with `Permission`

### Permission
Defines a specific permission that can be assigned to roles.
- `id`: UUID
- `name`: Permission name

## Admin Configuration
Admin interfaces have been configured for managing users, roles, and permissions using Django's `ModelAdmin`.

```python
from django.contrib import admin
from .models import User, Role, Permission

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('email', 'first_name', 'last_name', 'is_active')
    search_fields = ('email', 'first_name', 'last_name')
    filter_horizontal = ('roles',)

@admin.register(Role)
class RoleAdmin(admin.ModelAdmin):
    list_display = ('name',)
    search_fields = ('name',)
    filter_horizontal = ('permissions',)

@admin.register(Permission)
class PermissionAdmin(admin.ModelAdmin):
    list_display = ('name',)
    search_fields = ('name',)
```

## Permissions
Custom DRF permissions have been defined for different roles:
- `IsMechanic`
- `IsWorkshopOwner`
- `IsAdmin`
- `IsClient`

These permissions ensure that specific views are accessible only to users with the appropriate roles.

## API Endpoints

### Authentication
- `POST /login/`: Login a user and get JWT tokens.
- `POST /logout/`: Logout a user.
- `POST /register/`: Register a new user.
- `POST /token/refresh/`: Refresh JWT access token.

### Users
- `GET /users/`: List all users.
- `POST /users/`: Create a new user.
- `GET /users/{id}/`: Retrieve user details.
- `PUT /users/{id}/`: Update user details.
- `DELETE /users/{id}/`: Delete a user.

### Roles
- `GET /roles/`: List all roles.
- `POST /roles/`: Create a new role.
- `GET /roles/{id}/`: Retrieve role details.
- `PUT /roles/{id}/`: Update role details.
- `DELETE /roles/{id}/`: Delete a role.

### Permissions
- `GET /permissions/`: List all permissions.
- `POST /permissions/`: Create a new permission.
- `GET /permissions/{id}/`: Retrieve permission details.
- `PUT /permissions/{id}/`: Update permission details.
- `DELETE /permissions/{id}/`: Delete a permission.

### User Profile
- `GET /user/profile/`: Retrieve the current user's profile.
- `PUT /user/profile/`: Update the current user's profile (limited to certain roles).

## Signals
Django signals are used to handle post-save actions for users, such as logging the creation of a new user.

```python
from django.db.models.signals import post_save
from django.dispatch import receiver
from accounts.models import User

@receiver(post_save, sender=User)
def user_post_save(sender, instance, created, **kwargs):
    if created:
        print(f'Utworzono nowego użytkownika: {instance.email}')
```


