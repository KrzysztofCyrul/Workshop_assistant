import 'package:flutter/material.dart';
import 'package:flutter_frontend/features/workshop/presentation/screens/add_workshop_screen.dart';
import 'package:flutter_frontend/features/workshop/presentation/screens/get_temporary_code_screen.dart';
import '../settings/settings_screen.dart';
import '../relationships/client_statistics_screen.dart';
import '../relationships/send_email_screen.dart';
import '../quotations/quotations_screen.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/vehicle_list_screen.dart';
import 'package:flutter_frontend/features/clients/presentation/screens/clients_list_screen.dart';
import 'package:flutter_frontend/features/appointments/presentation/screens/appointments_list_screen.dart';
import 'package:flutter_frontend/features/workshop/presentation/screens/use_code_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          final user = state.user;
          final employeeProfiles = user.employeeProfiles;
          final isWorkshopOwner = user.roles.contains('workshop_owner');

          if (employeeProfiles.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (isWorkshopOwner) {
                Navigator.of(context).pushReplacementNamed(AddWorkshopScreen.routeName);
              } else {
                Navigator.of(context).pushReplacementNamed(UseCodeScreen.routeName);
              }
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final workshopId = employeeProfiles.first.workshopId;
          final employeeId = employeeProfiles.first.id;

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _navigateToSettings(context),
              ),
              title: const Text('Panel Główny'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _logout(context),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildWorkshopActions(context, workshopId, employeeId),
            ),
          );
        }

        // If not authenticated, redirect to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/login');
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildWorkshopActions(BuildContext context, String workshopId, String? employeeId) {
    final actions = [
      {
        'title': 'Zlecenia',
        'icon': Icons.assignment,
        'action': () => _navigateToAppointmentsList(context, workshopId),
      },
      {
        'title': 'Wyceny',
        'icon': Icons.description,
        'action': () => _navigateToQuotations(context, workshopId),
      },
      {
        'title': 'Klienci',
        'icon': Icons.people,
        'action': () => _navigateToClientsList(context, workshopId),
      },
      {
        'title': 'Pojazdy',
        'icon': Icons.directions_car,
        'action': () => _navigateToVehicleList(context, workshopId),
      },
      {
        'title': 'Statystyki Klientów',
        'icon': Icons.analytics,
        'action': () => _navigateToClientStatistics(context),
      },
      {
        'title': 'Wyślij E-mail',
        'icon': Icons.email,
        'action': () => _navigateToSendEmail(context, workshopId),
      },
      //TODO : Jak przechodzimy do ekranu getTemporaryCode to źle są przekazywane parametry
      {
        'title': 'Generuj kod',
        'icon': Icons.code,
        'action': () => _navigateToGetTemporaryCode(context, workshopId),
      },
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.2,
      ),
      itemCount: actions.length,
      itemBuilder: (ctx, index) {
        final action = actions[index];
        return Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.0),
            onTap: action['action'] as void Function()?,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    action['icon'] as IconData?,
                    size: 40.0,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    action['title'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToClientsList(BuildContext context, String workshopId) {
    Navigator.of(context).pushNamed(
      ClientsListScreen.routeName,
      arguments: {
        'workshopId': workshopId,
      },
    );
  }

  void _navigateToAppointmentsList(BuildContext context, String workshopId) {
    Navigator.of(context).pushNamed(
      AppointmentsListScreen.routeName,
      arguments: {
        'workshopId': workshopId,
      },
    );
  }

  void _navigateToVehicleList(BuildContext context, String workshopId) {
    Navigator.of(context).pushNamed(
      VehicleListScreen.routeName,
      arguments: {
        'workshopId': workshopId,
      },
    );
  }

  void _navigateToGetTemporaryCode(BuildContext context, String workshopId) {
    Navigator.of(context).pushNamed(
      GetTemporaryCodeScreen.routeName,
      arguments: {
        'workshopId': workshopId,
      },
    );
    Navigator.of(context).pushNamed(GetTemporaryCodeScreen.routeName);
  }

  void _logout(BuildContext context) {
    context.read<AuthBloc>().add(LogoutRequested());
  }

  void _navigateToClientStatistics(BuildContext context) {
    Navigator.of(context).pushNamed(ClientsStatisticsScreen.routeName);
  }

  void _navigateToSendEmail(BuildContext context, String workshopId) {
    Navigator.of(context).pushNamed(
      SendEmailScreen.routeName,
      arguments: {
        'workshopId': workshopId,
      },
    );
  }

  void _navigateToQuotations(BuildContext context, String workshopId) {
    Navigator.of(context).pushNamed(
      QuotationsScreen.routeName,
      arguments: {
        'workshopId': workshopId,
      },
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).pushNamed(SettingsScreen.routeName);
  }
}
