// register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/widgets/login_text_field.dart';
import '../../../../core/utils/validators.dart';

class RegisterScreen extends StatelessWidget {
  static const routeName = '/register';

  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    String selectedRole = 'mechanic';

    return Scaffold(
      appBar: AppBar(title: const Text('Rejestracja')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  CustomTextField(
                    controller: firstNameController,
                    label: 'Imię',
                    validator: (value) =>
                        Validators.requiredField(value, 'Imię'),
                  ),
                  CustomTextField(
                    controller: lastNameController,
                    label: 'Nazwisko',
                    validator: (value) =>
                        Validators.requiredField(value, 'Nazwisko'),
                  ),
                  CustomTextField(
                    controller: emailController,
                    label: 'Email',
                    validator: Validators.email,
                  ),
                  CustomTextField(
                    controller: passwordController,
                    label: 'Hasło',
                    obscureText: true,
                    validator: Validators.password,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(
                        value: 'mechanic',
                        child: Text('Mechanik'),
                      ),
                      DropdownMenuItem(
                        value: 'workshop_owner',
                        child: Text('Właściciel warsztatu'),
                      ),
                    ],
                    onChanged: (value) => selectedRole = value!,
                    decoration: const InputDecoration(
                      labelText: 'Rola',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                          RegisterRequested(
                            userData: {
                              'email': emailController.text,
                              'password': passwordController.text,
                              'first_name': firstNameController.text,
                              'last_name': lastNameController.text,
                              'role': selectedRole,
                            },
                          ),
                        );
                      }
                    },
                    child: const Text('Zarejestruj się'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Masz już konto? Zaloguj się'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}