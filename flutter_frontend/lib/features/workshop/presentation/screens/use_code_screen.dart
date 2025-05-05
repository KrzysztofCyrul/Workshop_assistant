import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/workshop_bloc.dart';

class UseCodeScreen extends StatefulWidget {
  static const routeName = '/use-code';

  const UseCodeScreen({super.key});

  @override
  State<UseCodeScreen> createState() => _UseCodeScreenState();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wprowadź kod'),
      ),
      body: BlocConsumer<WorkshopBloc, WorkshopState>(
        listener: (context, state) {
          if (state is WorkshopError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state is WorkshopOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                duration: const Duration(seconds: 2),
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
          return Padding(
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
                if (state is WorkshopLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () {
                      final code = _codeController.text.trim();
                      if (code.isNotEmpty) {
                        context.read<WorkshopBloc>().add(
                          UseTemporaryCodeEvent(code: code),
                        );
                      }
                    },
                    child: const Text('Zatwierdź'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}