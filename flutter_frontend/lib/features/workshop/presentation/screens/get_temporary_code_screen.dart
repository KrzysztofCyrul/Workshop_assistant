import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/workshop_bloc.dart';
import 'package:flutter_frontend/core/widgets/custom_app_bar.dart';

class GetTemporaryCodeScreen extends StatelessWidget {
  static const routeName = '/generate-code';
  final String? workshopId;

  const GetTemporaryCodeScreen({super.key, this.workshopId});

  @override
  Widget build(BuildContext context) {
    // Get workshopId from route if not provided in constructor
    final String? routeWorkshopId = workshopId ?? 
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?)?['workshopId'];    if (routeWorkshopId == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Błąd',
          feature: 'settings',
        ),
        body: const Center(
          child: Text('Brak wymaganego ID warsztatu'),
        ),
      );
    }    return Scaffold(
      appBar: CustomAppBar(
        title: 'Generuj kod',
        feature: 'settings',
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

          if (state is WorkshopUnauthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is WorkshopLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state is WorkshopError)
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                if (state is TemporaryCodeLoaded)
                  Column(
                    children: [
                      Text(
                        'Wygenerowany kod: ${state.temporaryCode.code}',
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Kod wygaśnie: ${state.temporaryCode.expiresAt.toLocal()}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<WorkshopBloc>().add(
                      LoadTemporaryCodeEvent(workshopId: routeWorkshopId),
                    );
                  },
                  child: const Text('Generuj kod'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
