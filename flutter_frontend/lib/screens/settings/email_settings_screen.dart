import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/email_settings.dart';
import '../../providers/email_provider.dart';
import '../../providers/auth_provider.dart';

class EmailSettingsScreen extends StatefulWidget {
  static const routeName = '/email-settings';

  const EmailSettingsScreen({super.key});

  @override
  _EmailSettingsScreenState createState() => _EmailSettingsScreenState();
}

class _EmailSettingsScreenState extends State<EmailSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _mailFromController;
  late TextEditingController _smtpHostController;
  late TextEditingController _smtpPortController;
  late TextEditingController _smtpUserController;
  late TextEditingController _smtpPasswordController;
  bool _useTls = false;

  // ignore: unused_field
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _mailFromController = TextEditingController();
    _smtpHostController = TextEditingController();
    _smtpPortController = TextEditingController();
    _smtpUserController = TextEditingController();
    _smtpPasswordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEmailSettings();
    });
  }

  Future<void> _loadEmailSettings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final emailProvider = Provider.of<EmailProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

    if (accessToken != null && workshopId != null) {
      try {
        await emailProvider.fetchEmailSettings(accessToken, workshopId);
        final emailSettings = emailProvider.emailSettings;

        setState(() {
          _mailFromController.text = emailSettings?.mailFrom ?? '';
          _smtpHostController.text = emailSettings?.smtpHost ?? '';
          _smtpPortController.text = emailSettings?.smtpPort.toString() ?? '';
          _smtpUserController.text = emailSettings?.smtpUser ?? '';
          _smtpPasswordController.text = emailSettings?.smtpPassword ?? '';
          _useTls = emailSettings?.useTls ?? false;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas ładowania ustawień e-mail: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _mailFromController.dispose();
    _smtpHostController.dispose();
    _smtpPortController.dispose();
    _smtpUserController.dispose();
    _smtpPasswordController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final emailProvider = context.read<EmailProvider>();
      final accessToken = authProvider.accessToken;
      final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

      if (accessToken == null || workshopId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Brak dostępu do danych użytkownika.')),
        );
        return;
      }

      final newSettings = EmailSettings(
        mailFrom: _mailFromController.text,
        smtpHost: _smtpHostController.text,
        smtpPort: int.tryParse(_smtpPortController.text) ?? 0,
        smtpUser: _smtpUserController.text,
        smtpPassword: _smtpPasswordController.text,
        useTls: _useTls,
      );

      try {
        await emailProvider.updateEmailSettings(
          accessToken,
          workshopId,
          newSettings,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ustawienia e-mail zostały zapisane.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas zapisywania ustawień e-mail: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailProvider = context.watch<EmailProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia e-mail'),
      ),
      body: emailProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                        controller: _mailFromController,
                        decoration: const InputDecoration(labelText: 'Mail From'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'To pole jest wymagane';
                          }
                          return null;
                        }),
                    TextFormField(
                      controller: _smtpHostController,
                      decoration: const InputDecoration(labelText: 'SMTP Host'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'To pole jest wymagane';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _smtpPortController,
                      decoration: const InputDecoration(labelText: 'SMTP Port'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || int.tryParse(value) == null) {
                          return 'Wprowadź poprawny port';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _smtpUserController,
                      decoration: const InputDecoration(labelText: 'SMTP User'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'To pole jest wymagane';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Wprowadź poprawny adres e-mail';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _smtpPasswordController,
                      decoration: const InputDecoration(labelText: 'SMTP Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'To pole jest wymagane';
                        }
                        return null;
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Użyj TLS'),
                      value: _useTls,
                      onChanged: (value) {
                        setState(() {
                          _useTls = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveSettings,
                      child: const Text('Zapisz'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
