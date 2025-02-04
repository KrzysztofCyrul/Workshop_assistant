import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/generate_code_provider.dart';

class GenerateCodeScreen extends StatelessWidget {
  static const routeName = '/generate-code';

  final String workshopId;

  const GenerateCodeScreen({Key? key, required this.workshopId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = authProvider.accessToken;

    if (accessToken == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Generuj kod'),
        ),
        body: const Center(
          child: Text('Brak dostępu do danych użytkownika.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generuj kod'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<GenerateCodeProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                if (provider.errorMessage != null)
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                if (provider.generatedCode != null)
                  Column(
                    children: [
                      Text(
                        'Wygenerowany kod: ${provider.generatedCode}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Kod wygaśnie: ${provider.expiresAt?.toLocal().toString()}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<GenerateCodeProvider>(context, listen: false)
                        .generateCode(workshopId, accessToken);
                  },
                  child: const Text('Generuj kod'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}