import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  const RegisterScreen({super.key});
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();
  final TextEditingController _firstNameController =
      TextEditingController();
  final TextEditingController _lastNameController =
      TextEditingController();

  String _selectedRole = 'client';
  final List<String> _roles = ['mechanic', 'workshop_owner', 'client'];

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> userData = {
      'email': _emailController.text,
      'password': _passwordController.text,
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'role': _selectedRole,
    };

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .register(userData);

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (e.toString().contains('errors')) {
        Map<String, dynamic> errors = e.toString() as Map<String, dynamic>;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errors.values.join('\n'))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejestracja'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email jest wymagany';
                    } else if (!isValidEmail(value)) {
                      return 'Nieprawidłowy format email';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Hasło',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hasło jest wymagane';
                    } else if (value.length < 8) {
                      return 'Hasło musi mieć co najmniej 8 znaków';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _firstNameController,
                  label: 'Imię',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Imię jest wymagane';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _lastNameController,
                  label: 'Nazwisko',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nazwisko jest wymagane';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: _roles.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Rola',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Rola jest wymagana';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _register,
                        child: const Text('Zarejestruj się'),
                      ),
                TextButton(
                  onPressed: _navigateToLogin,
                  child: const Text('Masz już konto? Zaloguj się'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
