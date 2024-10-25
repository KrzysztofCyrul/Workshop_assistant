from django.test import TestCase
from accounts.models.role import Role
from accounts.models.user import User


class UserModelTest(TestCase):
    def test_create_user(self):
        user = User.objects.create_user(email='test@example.com', password='testpass', name='Test User')
        self.assertEqual(user.email, 'test@example.com')
        self.assertTrue(user.check_password('testpass'))
        self.assertEqual(user.name, 'Test User')

class RoleModelTest(TestCase):
    def test_create_role(self):
        role = Role.objects.create(name='Administrator')
        self.assertEqual(role.name, 'Administrator')
