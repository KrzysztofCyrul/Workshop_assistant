import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/widgets/login_text_field.dart';
import '../../../../core/utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _selectedRole = 'mechanic';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      
      context.read<AuthBloc>().add(
        RegisterRequested(
          userData: {
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
            'first_name': _firstNameController.text.trim(),
            'last_name': _lastNameController.text.trim(),
            'role': _selectedRole,
          },
        ),
      );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Potwierdź hasło';
    }
    if (value != _passwordController.text) {
      return 'Hasła nie są identyczne';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: _handleAuthStateChanges,
          builder: (context, state) => _buildContent(context, state),
        ),
      ),
    );
  }

  void _handleAuthStateChanges(BuildContext context, AuthState state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else if (state is RegistrationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konto zostało utworzone pomyślnie! Możesz się teraz zalogować.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
      
      // Smooth transition back to login after a delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _navigateToLogin();
        }
      });
    }
  }

  Widget _buildContent(BuildContext context, AuthState state) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildRegistrationCard(context, state),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationCard(BuildContext context, AuthState state) {
    return Card(
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
              _buildHeader(context),
              const SizedBox(height: 32.0),
              _buildFormFields(context),
              const SizedBox(height: 32.0),
              _buildSubmitButton(context, state),
              const SizedBox(height: 24.0),
              _buildLoginLink(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: 'auth_icon',
          child: Icon(
            Icons.person_add_outlined,
            size: 48,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 24.0),
        Text(
          'Stwórz konto',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        Text(
          'Dołącz do Workshop Assistant',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: _firstNameController,
          label: 'Imię',
          validator: (value) => Validators.requiredField(value, 'Imię'),
          prefixIcon: Icon(Icons.person_outline, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 16.0),
        CustomTextField(
          controller: _lastNameController,
          label: 'Nazwisko',
          validator: (value) => Validators.requiredField(value, 'Nazwisko'),
          prefixIcon: Icon(Icons.person_outline, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 16.0),
        CustomTextField(
          controller: _emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
          prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 16.0),
        CustomTextField(
          controller: _passwordController,
          label: 'Hasło',
          obscureText: true,
          validator: Validators.password,
          prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 16.0),
        CustomTextField(
          controller: _confirmPasswordController,
          label: 'Potwierdź hasło',
          obscureText: true,
          validator: _validateConfirmPassword,
          prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 16.0),
        _buildRoleDropdown(context),
      ],
    );
  }

  Widget _buildRoleDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Rola',
        prefixIcon: Icon(Icons.work_outline, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
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
      onChanged: (value) => setState(() => _selectedRole = value!),
    );
  }

  Widget _buildSubmitButton(BuildContext context, AuthState state) {
    if (state is AuthLoading) {
      return Container(
        height: 56.0,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56.0,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 2.0,
        ),
        child: const Text(
          'Zarejestruj się',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Masz już konto? ',
          style: TextStyle(color: Colors.grey[600]),
        ),
        GestureDetector(
          onTap: _navigateToLogin,
          child: Text(
            'Zaloguj się',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}