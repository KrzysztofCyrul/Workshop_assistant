import 'package:flutter/material.dart';
import 'package:flutter_frontend/features/workshop/presentation/screens/add_workshop_screen.dart';
import 'package:flutter_frontend/features/workshop/presentation/screens/get_temporary_code_screen.dart';
// import '../settings/settings_screen.dart';
// Zakomentowane importy będą potrzebne w przyszłości, gdy funkcjonalność zostanie dodana
// import '../relationships/client_statistics_screen.dart';
// import '../relationships/send_email_screen.dart';
import 'package:flutter_frontend/features/quotations/presentation/screens/quotations_list_screen.dart';
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
          final employeeId = employeeProfiles.first.id;          return Scaffold(
            appBar: AppBar(
              // leading: IconButton(
              //   icon: const Icon(Icons.settings),
              //   onPressed: () => _navigateToSettings(context),
              // ),
              title: const Text(
                'Panel Główny',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              centerTitle: true,
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _logout(context),
                ),
                const SizedBox(width: 8),
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
  }  Widget _buildWorkshopActions(BuildContext context, String workshopId, String? employeeId) {
    // Grupowanie elementów według funkcji dla lepszej organizacji
    final mainActions = [
      {
        'title': 'Zlecenia',
        'subtitle': 'Zarządzaj zleceniami',
        'icon': Icons.assignment,
        'color': Colors.blue.shade700,
        'action': () => _navigateToAppointmentsList(context, workshopId),
      },
      {
        'title': 'Wyceny',
        'subtitle': 'Twórz i przeglądaj wyceny',
        'icon': Icons.description,
        'color': Colors.indigo.shade600,
        'action': () => _navigateToQuotations(context, workshopId),
      },
    ];
    
    final resourcesActions = [
      {
        'title': 'Klienci',
        'subtitle': 'Baza klientów',
        'icon': Icons.people,
        'color': Colors.green.shade700,
        'action': () => _navigateToClientsList(context, workshopId),
      },
      {
        'title': 'Pojazdy',
        'subtitle': 'Zarządzaj pojazdami',
        'icon': Icons.directions_car,
        'color': Colors.orange.shade700,
        'action': () => _navigateToVehicleList(context, workshopId),
      },
    ];
    
    final adminActions = [
      {
        'title': 'Generuj kod',
        'subtitle': 'Dostęp dla pracowników',
        'icon': Icons.qr_code,
        'color': Colors.purple.shade700,
        'action': () => _navigateToGetTemporaryCode(context, workshopId),
      },
      // Miejsce na przyszłe funkcje
      // {
      //   'title': 'Statystyki',
      //   'subtitle': 'Analiza danych',
      //   'icon': Icons.analytics,
      //   'color': Colors.teal.shade700,
      //   'action': () => _navigateToClientStatistics(context),
      // },
    ];
    
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // SliverToBoxAdapter(
        //   child: Padding(
        //     padding: const EdgeInsets.only(left: 2.0, bottom: 16.0, top: 8.0),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Text(
        //           'Witaj w warsztacie',
        //           style: TextStyle(
        //             fontSize: 24,
        //             fontWeight: FontWeight.bold,
        //             color: Colors.blue.shade900,
        //           ),
        //         ),
        //         const SizedBox(height: 6),
        //         Text(
        //           'Wybierz jedną z opcji, aby rozpocząć pracę',
        //           style: TextStyle(
        //             fontSize: 14,
        //             color: Colors.grey.shade700,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        
        // Główne funkcje
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 2.0, top: 24.0, bottom: 8.0),
            child: Text(
              'Obsługa zleceń',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mainActions.length,
              itemBuilder: (context, index) {
                final action = mainActions[index];
                return Container(
                  // Zmieniam szerokość karty, aby dopasować ją do szerokości siatki
                  // To sprawi, że karty będą miały szerokość połowy ekranu minus padding
                  width: (MediaQuery.of(context).size.width - 48) / 2,
                  margin: const EdgeInsets.only(right: 16.0),
                  child: Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.0),
                      onTap: action['action'] as void Function()?,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [action['color'] as Color, (action['color'] as Color).withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        padding: const EdgeInsets.all(16.0), // Zmniejszamy padding dla lepszego dopasowania
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Icon(
                                action['icon'] as IconData,
                                size: 30.0,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Text(
                              action['title'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              action['subtitle'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12.0,
                              ),
                              overflow: TextOverflow.ellipsis, // Zapobiega przepełnieniu tekstu
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        // Zarządzanie bazą
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 2.0, top: 24.0, bottom: 8.0),
            child: Text(
              'Baza danych',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: resourcesActions.length,
              itemBuilder: (context, index) {
                final action = resourcesActions[index];
                return Container(
                  width: (MediaQuery.of(context).size.width - 48) / 2,
                  margin: const EdgeInsets.only(right: 16.0),
                  child: Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.0),
                      onTap: action['action'] as void Function()?,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [action['color'] as Color, (action['color'] as Color).withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Icon(
                                action['icon'] as IconData,
                                size: 30.0,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Text(
                              action['title'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              action['subtitle'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        // Funkcje administracyjne
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 2.0, top: 24.0, bottom: 8.0),
            child: Text(
              'Administracja',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: adminActions.length,
              itemBuilder: (context, index) {
                final action = adminActions[index];
                return Container(
                  width: (MediaQuery.of(context).size.width - 48) / 2,
                  margin: const EdgeInsets.only(right: 16.0),
                  child: Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.0),
                      onTap: action['action'] as void Function()?,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [action['color'] as Color, (action['color'] as Color).withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Icon(
                                action['icon'] as IconData,
                                size: 30.0,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Text(
                              action['title'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              action['subtitle'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
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
    // Usunięto niepotrzebne drugie wywołanie nawigacji
  }

  void _logout(BuildContext context) {
    context.read<AuthBloc>().add(LogoutRequested());
  }
  // Funkcje te mogą być przywrócone w przyszłości, gdy zostanie dodana funkcjonalność
  /*
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
  */void _navigateToQuotations(BuildContext context, String workshopId) {
    Navigator.of(context).pushNamed(
      QuotationsListScreen.routeName,
      arguments: {
        'workshopId': workshopId,
      },
    );
  }

  // void _navigateToSettings(BuildContext context) {
  //   Navigator.of(context).pushNamed(SettingsScreen.routeName);
  // }
}
