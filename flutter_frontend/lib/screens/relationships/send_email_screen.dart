import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/client.dart';
import '../../models/employee.dart';
import '../../providers/auth_provider.dart';
import '../../providers/email_provider.dart';
import '../../providers/employee_provider.dart';
import '../../services/client_service.dart';
import '../../services/chatgpt_service.dart'; // Dodano ChatGPT Service
import '../../widgets/client_serach_widget.dart';

class SendEmailScreen extends StatefulWidget {
  static const routeName = '/send-email';

  const SendEmailScreen({Key? key}) : super(key: key);

  @override
  _SendEmailScreenState createState() => _SendEmailScreenState();
}

class _SendEmailScreenState extends State<SendEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  String _recipientType = 'all';
  String? _selectedSegment;
  Client? _selectedClient;

  List<Client> _clients = [];
  // ignore: unused_field
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

    if (accessToken == null || workshopId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      _clients = await ClientService.getClients(accessToken, workshopId);
    } catch (e) {
      setState(() {
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateEmailContent(Employee employee) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = authProvider.accessToken;

      if (accessToken == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final generatedEmail = await ChatGPTService.generateEmail(
        accessToken: accessToken,
        subjectHint: _subjectController.text,
        recipientType: _recipientType,
        selectedSegment: _selectedSegment,
        selectedClient: _selectedClient?.email,
        senderName: employee.userFullName,
        senderPosition: employee.position,
        senderCompany: employee.workshopName,
      );

      setState(() {
        _bodyController.text = generatedEmail;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Treść wiadomości została wygenerowana.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas generowania treści: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _sendEmail(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

    if (accessToken == null || workshopId == null) {
      setState(() {
      });
      return;
    }

    final emailProvider = Provider.of<EmailProvider>(context, listen: false);

    List<String> recipients = [];
    if (_recipientType == 'all') {
      recipients = _clients.map((client) => client.email).toList();
    } else if (_recipientType == 'segment') {
      recipients = _clients
          .where((client) => client.segment == _selectedSegment)
          .map((client) => client.email)
          .toList();
    } else if (_recipientType == 'single' && _selectedClient != null) {
      recipients = [_selectedClient!.email];
    }

    try {
      if (emailProvider.emailSettings == null) {
        await emailProvider.fetchEmailSettings(accessToken, workshopId);

        if (emailProvider.errorMessage != null) {
          setState(() {
          });
          return;
        }
      }

      await emailProvider.sendEmailLocally(
        subject: _subjectController.text,
        body: _bodyController.text,
        recipients: recipients,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wiadomość została wysłana.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;
    final workshopId = authProvider.user?.employeeProfiles.first.workshopId;

    if (accessToken == null || workshopId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Wyślij e-mail'),
        ),
        body: const Center(
          child: Text('Brak dostępu do danych użytkownika.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wyślij e-mail'),
      ),
      body: FutureBuilder(
        future: Provider.of<EmployeeProvider>(context, listen: false).fetchEmployeeDetails(
          accessToken,
          workshopId,
          authProvider.user!.employeeProfiles.first.id, // Pobieramy pierwszy profil pracownika
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          } else {
            return Consumer<EmployeeProvider>(
              builder: (context, provider, child) {
                final employee = provider.employee;
                if (employee == null) {
                  return const Center(child: Text('Nie znaleziono pracownika.'));
                }
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _subjectController,
                          decoration: const InputDecoration(
                            labelText: 'Temat wiadomości',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Podaj temat wiadomości.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _bodyController,
                                decoration: const InputDecoration(
                                  labelText: 'Treść wiadomości',
                                ),
                                maxLines: 15,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Podaj treść wiadomości.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.auto_awesome),
                              onPressed: () => _generateEmailContent(employee),
                              tooltip: 'Wygeneruj treść',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _recipientType,
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('Do wszystkich klientów'),
                            ),
                            DropdownMenuItem(
                              value: 'segment',
                              child: Text('Do klientów w segmencie'),
                            ),
                            DropdownMenuItem(
                              value: 'single',
                              child: Text('Do pojedynczego klienta'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _recipientType = value ?? 'all';
                              _selectedSegment = null;
                              _selectedClient = null;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Odbiorcy',
                          ),
                        ),
                        if (_recipientType == 'segment') ...[
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedSegment,
                            items: ['A', 'B', 'C', 'D']
                                .map((segment) => DropdownMenuItem(
                                      value: segment,
                                      child: Text('Segment $segment'),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSegment = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Wybierz segment',
                            ),
                          ),
                        ],
                        if (_recipientType == 'single') ...[
                          const SizedBox(height: 16),
                          ClientSearchWidget(
                            onChanged: (value) {
                              setState(() {
                                _selectedClient = value;
                              });
                            },
                            validator: (client) =>
                                client == null ? 'Wybierz klienta' : null,
                          ),
                        ],
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _sendEmail(context),
                          child: const Text('Wyślij'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
