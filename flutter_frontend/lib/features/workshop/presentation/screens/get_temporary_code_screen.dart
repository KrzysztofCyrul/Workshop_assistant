import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../bloc/workshop_bloc.dart';
import 'package:flutter_frontend/core/widgets/custom_app_bar.dart';

class GetTemporaryCodeScreen extends StatefulWidget {
  static const routeName = '/generate-code';
  final String? workshopId;

  const GetTemporaryCodeScreen({super.key, this.workshopId});

  @override
  State<GetTemporaryCodeScreen> createState() => _GetTemporaryCodeScreenState();
}

class _GetTemporaryCodeScreenState extends State<GetTemporaryCodeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _codeAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _codeAnimationController = AnimationController(
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
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _codeAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _codeAnimationController.dispose();
    super.dispose();
  }

  void _copyCodeToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kod został skopiowany do schowka'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatExpirationTime(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);
    
    if (difference.isNegative) {
      return 'Kod wygasł';
    }
    
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    if (hours > 0) {
      return 'Wygasa za ${hours}h ${minutes}min';
    } else {
      return 'Wygasa za ${minutes}min';
    }
  }
  @override
  Widget build(BuildContext context) {
    // Get workshopId from route if not provided in constructor
    final String? routeWorkshopId = widget.workshopId ?? 
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?)?['workshopId'];

    if (routeWorkshopId == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: CustomAppBar(
          title: 'Błąd',
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
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(24.0),
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Błąd',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.red[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Brak wymaganego ID warsztatu',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(
        title: 'Generuj kod tymczasowy',
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

            if (state is TemporaryCodeLoaded) {
              _codeAnimationController.forward();
            }

            if (state is WorkshopUnauthenticated) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Hero(
                                tag: 'generate_code_icon',
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.qr_code_2,
                                    size: 48,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24.0),
                              Text(
                                'Generator kodów tymczasowych',
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
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                    width: 1.0,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.orange.shade600,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Generowany kod będzie ważny przez ograniczony czas',
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      'Przekaż go mechanikowi, aby mógł dołączyć do warsztatu',
                                      style: TextStyle(
                                        color: Colors.orange.shade600,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24.0),
                              
                              // Generated code display
                              if (state is TemporaryCodeLoaded)
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Container(
                                    padding: const EdgeInsets.all(20.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context).primaryColor.withOpacity(0.1),
                                          Theme.of(context).primaryColor.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Wygenerowany kod:',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 12.0),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0,
                                            vertical: 12.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 8.0,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                state.temporaryCode.code,
                                                style: TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).primaryColor,
                                                  letterSpacing: 4.0,
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () => _copyCodeToClipboard(state.temporaryCode.code),
                                                icon: Icon(
                                                  Icons.copy,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                                tooltip: 'Skopiuj kod',
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16.0),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 8.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color: Colors.red.shade200,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.schedule,
                                                size: 16,
                                                color: Colors.red.shade600,
                                              ),
                                              const SizedBox(width: 8.0),
                                              Text(
                                                _formatExpirationTime(state.temporaryCode.expiresAt),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.red.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              
                              const SizedBox(height: 32.0),
                              
                              // Generate button
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
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _codeAnimationController.reset();
                                      context.read<WorkshopBloc>().add(
                                        LoadTemporaryCodeEvent(workshopId: routeWorkshopId),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      elevation: 2.0,
                                    ),
                                    icon: const Icon(Icons.refresh),
                                    label: Text(
                                      state is TemporaryCodeLoaded ? 'Wygeneruj nowy kod' : 'Generuj kod',
                                      style: const TextStyle(
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
                                  'Powrót',
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
            );
          },
        ),
      ),
    );
  }
}
