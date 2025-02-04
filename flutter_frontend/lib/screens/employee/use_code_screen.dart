import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/temporary_code_provider.dart';

class UseCodeScreen extends StatefulWidget {
  static const routeName = '/use-code';

  const UseCodeScreen({Key? key}) : super(key: key);

  @override
  _UseCodeScreenState createState() => _UseCodeScreenState();
}

class _UseCodeScreenState extends State<UseCodeScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    if (accessToken == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Wprowadź kod'),
        ),
        body: const Center(
          child: Text('Brak dostępu do danych użytkownika.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wprowadź kod'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Kod',
                hintText: 'Wprowadź 6-cyfrowy kod',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final code = _codeController.text.trim();
                if (code.isNotEmpty) {
                  Provider.of<TemporaryCodeProvider>(context, listen: false)
                      .useCode(code, accessToken);
                }
              },
              child: const Text('Zatwierdź'),
            ),
            const SizedBox(height: 20),
            Consumer<TemporaryCodeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const CircularProgressIndicator();
                } else if (provider.errorMessage != null) {
                  return Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  );
                } else if (provider.successMessage != null) {
                  return Text(
                    provider.successMessage!,
                    style: const TextStyle(color: Colors.green),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}