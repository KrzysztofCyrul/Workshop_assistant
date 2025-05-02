import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../../../screens/home/home_screen.dart';
import '../../../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _rememberMe = false;

  static const String _emailKey = 'saved_email';
  static const String _passwordKey = 'saved_password';
  static const String _rememberMeKey = 'remember_me';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final savedRememberMe = await _storage.read(key: _rememberMeKey) == 'true';
      if (savedRememberMe) {
        final savedEmail = await _storage.read(key: _emailKey);
        final savedPassword = await _storage.read(key: _passwordKey);
        
        if (mounted) {
          setState(() {
            _rememberMe = savedRememberMe;
            emailController.text = savedEmail ?? '';
            passwordController.text = savedPassword ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading credentials: $e');
    }
  }

  Future<void> _saveCredentials() async {
    try {
      if (_rememberMe) {
        await _storage.write(key: _emailKey, value: emailController.text);
        await _storage.write(key: _passwordKey, value: passwordController.text);
        await _storage.write(key: _rememberMeKey, value: _rememberMe.toString());
      } else {
        await _storage.deleteAll();
      }
    } catch (e) {
      debugPrint('Error saving credentials: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor.withOpacity(0.2),
            ],
          ),
        ),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            print('Current state: $state'); // Debug line
            
            if (state is Authenticated) {
              // Use pushNamedAndRemoveUntil to clear the navigation stack
              Navigator.of(context).pushNamedAndRemoveUntil(
                HomeScreen.routeName, // Zmiana z '/home' na HomeScreen.routeName
                (Route<dynamic> route) => false,
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 12.0,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 48,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 24.0),
                            Text(
                              'Witaj ponownie!',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Zaloguj się do swojego konta',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32.0),
                            CustomTextField(
                              controller: emailController,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                              prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).primaryColor),
                            ),
                            const SizedBox(height: 16.0),
                            CustomTextField(
                              controller: passwordController,
                              label: 'Hasło',
                              obscureText: true,
                              validator: Validators.password,
                              prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).primaryColor),
                            ),
                            const SizedBox(height: 8.0),
                            CheckboxListTile(
                              title: Text(
                                'Zapamiętaj mnie',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              value: _rememberMe,
                              onChanged: (bool? value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 32.0),
                            if (state is AuthLoading)
                              const Center(child: CircularProgressIndicator())
                            else
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 56.0,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      await _saveCredentials();
                                      if (mounted) {
                                        context.read<AuthBloc>().add(
                                          LoginRequested(
                                            email: emailController.text,
                                            password: passwordController.text,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Theme.of(context).primaryColor,
                                    elevation: 4,
                                    shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                  ),
                                  child: const Text(
                                    'Zaloguj się',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Nie masz konta? ',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(context, '/register'),
                                  child: Text(
                                    'Zarejestruj się',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}