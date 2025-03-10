import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/appointment.dart' as workshop_appointment;
import '../../services/appointment_service.dart';
import 'appointment_details_screen.dart';
import 'add_appointment_screen.dart';

class AppointmentCalendarScreen extends StatefulWidget {
  static const routeName = '/appointments_calendar';

  const AppointmentCalendarScreen({super.key});

  @override
  _AppointmentCalendarScreenState createState() =>
      _AppointmentCalendarScreenState();
}

class _AppointmentCalendarScreenState extends State<AppointmentCalendarScreen> {
  late Future<List<workshop_appointment.Appointment>> _scheduledAppointmentsFuture;
  String? _workshopId;
  
  final CalendarController _calendarController = CalendarController();

  // Ustawienia widoku i nawigacji kalendarza
  final bool _showDatePickerButton = true;
  final bool _allowViewNavigation = true;
  final bool _showCurrentTimeIndicator = true;
  final bool _showLeadingAndTrailingDates = true;

  @override
  void initState() {
    super.initState();
    _scheduledAppointmentsFuture = _fetchScheduledAppointments();
    _calendarController.view = CalendarView.month; // Domyślny widok
  }

  Future<List<workshop_appointment.Appointment>> _fetchScheduledAppointments() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      throw Exception('Brak danych użytkownika');
    }

    bool isMechanic = user.roles.contains('mechanic') || user.roles.contains('workshop_owner');
    bool isAssignedToWorkshop = user.employeeProfiles.isNotEmpty;

    if (isMechanic && isAssignedToWorkshop) {
      final employee = user.employeeProfiles.first;
      _workshopId = employee.workshopId;

      final appointmentService = AppointmentService();
      List<workshop_appointment.Appointment> appointments = await appointmentService.getAppointments(
        authProvider.accessToken!,
        _workshopId!,
      );

      appointments = appointments.where((appointment) => appointment.status.toLowerCase() == 'pending').toList();
      appointments.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      return appointments;
    } else {
      throw Exception('Nie masz uprawnień do wyświetlenia tej strony');
    }
  }

  Future<void> _refreshScheduledAppointments() async {
    setState(() {
      _scheduledAppointmentsFuture = _fetchScheduledAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Możesz dostosować styl i motyw wedle własnych potrzeb.
    // Poniżej przykładowy neutralny Theme:
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktualne wizyty'),
        actions: [

          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Dodaj zlecenie',
            onPressed: _navigateToAddAppointment,
          ),
        ],
      ),
      body: FutureBuilder<List<workshop_appointment.Appointment>>(
        future: _scheduledAppointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _refreshScheduledAppointments,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Ponów próbę'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Brak zaplanowanych zleceń.',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            final appointments = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshScheduledAppointments,
              child: _buildCalendar(appointments, theme),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddAppointment,
        tooltip: 'Dodaj zlecenie',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendar(List<workshop_appointment.Appointment> appointments, ThemeData theme) {
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          secondary: theme.primaryColor,
        ),
      ),
      child: SfCalendar(
        controller: _calendarController,
        dataSource: WorkshopAppointmentDataSource(appointments),
        allowedViews: const [
          CalendarView.day,
          CalendarView.week,
          CalendarView.workWeek,
          CalendarView.timelineDay,
          CalendarView.timelineWeek,
          CalendarView.timelineWorkWeek,
          CalendarView.month,
          CalendarView.schedule
        ],
        showDatePickerButton: _showDatePickerButton,
        allowViewNavigation: _allowViewNavigation,
        showCurrentTimeIndicator: _showCurrentTimeIndicator,
        showNavigationArrow: false,
        viewNavigationMode: ViewNavigationMode.snap,
        timeSlotViewSettings: const TimeSlotViewSettings(
          numberOfDaysInView: -1, // domyślna liczba dni w widoku
          minimumAppointmentDuration: Duration(minutes: 60),
        ),
        monthViewSettings: MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          showTrailingAndLeadingDates: _showLeadingAndTrailingDates,
        ),
        scheduleViewMonthHeaderBuilder: scheduleViewBuilder, // z przykładu
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
            final selectedAppointment = details.appointments!.first as workshop_appointment.Appointment;
            _navigateToAppointmentDetails(selectedAppointment);
          }
        },
        appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
          final apt = details.appointments.first as workshop_appointment.Appointment;
          return Container(
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _getStatusColor(apt.status),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${apt.vehicle.make} ${apt.vehicle.model}\n'
              '${DateFormat('HH:mm').format(apt.scheduledTime.toLocal())}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          );
        },
        onLongPress: (CalendarLongPressDetails details) {
          if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
            final selectedAppointment = details.appointments!.first as workshop_appointment.Appointment;
            _showChangeStatusPopup(selectedAppointment);
          }
        },
      ),
    );
  }

  void _showChangeStatusPopup(workshop_appointment.Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Zmień status wizyty'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () {
                  _updateAppointmentStatus(appointment, 'completed');
                  Navigator.pop(context);
                },
                tooltip: 'Zakończone',
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  _updateAppointmentStatus(appointment, 'canceled');
                  Navigator.pop(context);
                },
                tooltip: 'Anulowane',
              ),
              IconButton(
                icon: const Icon(Icons.pending, color: Colors.orange),
                onPressed: () {
                  _updateAppointmentStatus(appointment, 'pending');
                  Navigator.pop(context);
                },
                tooltip: 'Oczekujące',
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateAppointmentStatus(workshop_appointment.Appointment appointment, String newStatus) async {
    try {
      await AppointmentService.updateAppointmentStatus(
        appointmentId: appointment.id,
        status: newStatus,
        accessToken: Provider.of<AuthProvider>(context, listen: false).accessToken!,
        workshopId: _workshopId!,
      );
      _refreshScheduledAppointments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się zmienić statusu: $e')),
      );
    }
  }

  void _navigateToAddAppointment() async {
    final result = await Navigator.pushNamed(
      context,
      AddAppointmentScreen.routeName,
    );

    if (result == true) {
      _refreshScheduledAppointments();
    }
  }

  void _navigateToAppointmentDetails(workshop_appointment.Appointment appointment) {
    Navigator.pushNamed(
      context,
      AppointmentDetailsScreen.routeName,
      arguments: {
        'workshopId': _workshopId!,
        'appointmentId': appointment.id,
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

// Funkcja buildera dla widoku Schedule (analogiczna do przykładu)
Widget scheduleViewBuilder(
    BuildContext buildContext, ScheduleViewMonthHeaderDetails details) {
  final String monthName = _getMonthDate(details.date.month);
  return Stack(
    children: <Widget>[
      Image(
          image: ExactAssetImage('images/$monthName.png'),
          fit: BoxFit.cover,
          width: details.bounds.width,
          height: details.bounds.height),
      Positioned(
        left: 55,
        top: 20,
        child: Text(
          '$monthName ${details.date.year}',
          style: const TextStyle(fontSize: 18, color: Colors.black),
        ),
      )
    ],
  );
}

String _getMonthDate(int month) {
  switch (month) {
    case 1:
      return 'January';
    case 2:
      return 'February';
    case 3:
      return 'March';
    case 4:
      return 'April';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'August';
    case 9:
      return 'September';
    case 10:
      return 'October';
    case 11:
      return 'November';
    default:
      return 'December';
  }
}

class WorkshopAppointmentDataSource extends CalendarDataSource {

  WorkshopAppointmentDataSource(
    List<workshop_appointment.Appointment> source,
  ) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    final apt = appointments![index] as workshop_appointment.Appointment;
    return apt.scheduledTime.toLocal();
  }

  @override
  DateTime getEndTime(int index) {
    final apt = appointments![index] as workshop_appointment.Appointment;
    Duration totalDuration = Duration.zero;
    if (apt.repairItems.isNotEmpty) {
      for (var item in apt.repairItems) {
        totalDuration += (item.estimatedDuration ?? Duration.zero);
      }
      if (totalDuration == Duration.zero) {
        totalDuration = const Duration(hours: 1);
      }
    } else {
      totalDuration = const Duration(hours: 1);
    }

    return apt.scheduledTime.toLocal().add(totalDuration);
  }

  @override
  String getSubject(int index) {
    final apt = appointments![index] as workshop_appointment.Appointment;
    return '${apt.vehicle.make} ${apt.vehicle.model} - ${apt.client.firstName} ${apt.client.lastName}';
  }

  @override
  Color getColor(int index) {
    final apt = appointments![index] as workshop_appointment.Appointment;

    Color defaultColor;
    switch (apt.status.toLowerCase()) {
      case 'completed':
        defaultColor = Colors.green;
        break;
      case 'pending':
        defaultColor = Colors.orange;
        break;
      case 'canceled':
        defaultColor = Colors.red;
        break;
      default:
        defaultColor = Colors.blue;
        break;
    }

    // Jeśli brak przypisanego koloru mechanika lub brak mechaników, użyj domyślnego
    return defaultColor;
  }

  @override
  bool isAllDay(int index) {
    return false;
  }
}
