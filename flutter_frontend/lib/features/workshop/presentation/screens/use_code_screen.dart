import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/workshop_bloc.dart';
import 'package:flutter_frontend/core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/login_text_field.dart';

class UseCodeScreen extends StatefulWidget {
  static const routeName = '/use-code';

  const UseCodeScreen({super.key});

  @override
  State<UseCodeScreen> createState() => _UseCodeScreenState();
}

class _UseCodeScreenState extends State<UseCodeScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
    _codeController.dispose();
    super.dispose();
  }

  void _submitCode() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final code = _codeController.text.trim();
      context.read<WorkshopBloc>().add(
        UseTemporaryCodeEvent(code: code),
      );
    }
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(
        title: 'Wprowadź kod',
        feature: 'settings',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: BlocConsumer<WorkshopBloc, WorkshopState>(
          listener: (context, state) {
            if (state is WorkshopError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }

            if (state is WorkshopOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            }

            if (state is WorkshopUnauthenticated) {
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
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
                                Hero(
                                  tag: 'code_icon',
                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.qr_code_scanner,
                                      size: 48,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24.0),
                                Text(
                                  'Wprowadź kod dostępu',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16.0),
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: Colors.blue.shade200,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.blue.shade600,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Kod tymczasowy powinien być wygenerowany przez właściciela warsztatu',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        'Kod składa się z 6 cyfr i jest ważny przez ograniczony czas',
                                        style: TextStyle(
                                          color: Colors.blue.shade600,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24.0),
                                CustomTextField(
                                  controller: _codeController,
                                  label: 'Kod tymczasowy',
                                  keyboardType: TextInputType.number,
                                  prefixIcon: Icon(
                                    Icons.vpn_key,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Wprowadź kod';
                                    }
                                    if (value.length != 6) {
                                      return 'Kod musi składać się z 6 cyfr';
                                    }
                                    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                                      return 'Kod może zawierać tylko cyfry';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32.0),
                                if (state is WorkshopLoading)
                                  Container(
                                    height: 56.0,
                                    alignment: Alignment.center,
                                    child: const CircularProgressIndicator(),
                                  )
                                else
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    height: 56.0,
                                    child: ElevatedButton(
                                      onPressed: _submitCode,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                        elevation: 2.0,
                                      ),
                                      child: const Text(
                                        'Zatwierdź kod',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16.0),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey[600],
                                  ),
                                  child: const Text(
                                    'Anuluj',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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