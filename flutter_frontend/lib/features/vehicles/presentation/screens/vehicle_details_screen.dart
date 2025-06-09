import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/vehicles/domain/entities/service_record.dart';
import 'package:flutter_frontend/features/vehicles/presentation/bloc/vehicle_bloc.dart';
import 'package:flutter_frontend/features/vehicles/presentation/screens/vehicle_edit_screen.dart';
import 'package:flutter_frontend/core/widgets/custom_app_bar.dart';
import 'package:flutter_frontend/core/theme/app_theme.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/details_card_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/detail_row_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/vehicle_profile_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/empty_state_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/loading_indicator.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/error_state_widget.dart';
import 'package:intl/intl.dart';

class VehicleDetailsScreen extends StatefulWidget {
  static const routeName = '/vehicle-details';
  final String vehicleId;
  final String workshopId;

  const VehicleDetailsScreen({
    super.key,
    required this.vehicleId,
    required this.workshopId,
  });

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadVehicleDetails();
    _loadServiceRecords();
  }

  void _loadVehicleDetails() {
    if (mounted) {
      context.read<VehicleBloc>().add(LoadVehicleDetailsEvent(
        workshopId: widget.workshopId,
        vehicleId: widget.vehicleId,
      ));
    }
  }

  void _loadServiceRecords() {
    if (mounted) {
      context.read<VehicleBloc>().add(LoadServiceRecordsEvent(
        workshopId: widget.workshopId,
        vehicleId: widget.vehicleId,
      ));
    }
  }

  String _formatDate(DateTime date) => DateFormat('dd.MM.yyyy HH:mm').format(date);

  Widget _buildContent(BuildContext context, dynamic vehicle, List<ServiceRecord> serviceRecords) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVehicleDetailsCard(context, vehicle),
          const SizedBox(height: 16.0),
          _buildSystemInfoCard(vehicle),
          const SizedBox(height: 16.0),
          _buildServiceHistoryCard(serviceRecords),
        ],
      ),
    );
  }

  Widget _buildVehicleDetailsCard(BuildContext context, dynamic vehicle) {
    final vehicleFeatureColor = AppTheme.getFeatureColor('vehicles');
    
    return DetailsCardWidget(
      title: 'Szczegóły Pojazdu',
      subtitle: '${vehicle.make} ${vehicle.model}',
      icon: Icons.directions_car,
      iconBackgroundColor: vehicleFeatureColor.withOpacity(0.2),
      iconColor: vehicleFeatureColor,
      initiallyExpanded: true,
      children: [
        // Vehicle profile widget
        VehicleProfileWidget(
          make: vehicle.make,
          model: vehicle.model,
          licensePlate: vehicle.licensePlate,
        ),
        
        // Vehicle details
        DetailRowWidget(
          label: 'Marka',
          value: vehicle.make,
          icon: Icons.category,
          iconColor: vehicleFeatureColor,
        ),
        DetailRowWidget(
          label: 'Model',
          value: vehicle.model,
          icon: Icons.style,
          iconColor: vehicleFeatureColor,
        ),
        DetailRowWidget(
          label: 'Rok produkcji',
          value: vehicle.year.toString(),
          icon: Icons.calendar_today,
          iconColor: vehicleFeatureColor,
        ),
        DetailRowWidget(
          label: 'Nr rejestracyjny',
          value: vehicle.licensePlate,
          icon: Icons.badge,
          iconColor: vehicleFeatureColor,
        ),
        DetailRowWidget(
          label: 'VIN',
          value: vehicle.vin,
          icon: Icons.tag,
          iconColor: vehicleFeatureColor,
        ),
        DetailRowWidget(
          label: 'Przebieg',
          value: '${vehicle.mileage} km',
          icon: Icons.speed,
          iconColor: vehicleFeatureColor,
        ),
      ],
    );
  }

  Widget _buildSystemInfoCard(dynamic vehicle) {
    return DetailsCardWidget(
      title: 'Informacje systemowe',
      subtitle: 'Dane techniczne',
      icon: Icons.settings,
      iconBackgroundColor: Colors.grey.shade100,
      iconColor: Colors.grey.shade600,
      initiallyExpanded: false,
      children: [
        DetailRowWidget(
          label: 'ID pojazdu',
          value: vehicle.id,
          icon: Icons.fingerprint,
          iconColor: Colors.grey.shade600,
        ),
        DetailRowWidget(
          label: 'Data utworzenia',
          value: _formatDate(vehicle.createdAt),
          icon: Icons.access_time,
          iconColor: Colors.grey.shade600,
        ),
        DetailRowWidget(
          label: 'Ostatnia aktualizacja',
          value: _formatDate(vehicle.updatedAt),
          icon: Icons.update,
          iconColor: Colors.grey.shade600,
        ),
      ],
    );
  }

  Widget _buildServiceHistoryCard(List<ServiceRecord> serviceRecords) {
    final vehicleFeatureColor = AppTheme.getFeatureColor('vehicles');
    
    return DetailsCardWidget(
      title: 'Historia serwisowa',
      subtitle: serviceRecords.isEmpty 
          ? 'Brak wpisów' 
          : '${serviceRecords.length} ${serviceRecords.length == 1 ? 'wpis' : 'wpisów'}',
      icon: Icons.history,
      iconBackgroundColor: vehicleFeatureColor.withOpacity(0.1),
      iconColor: vehicleFeatureColor,
      initiallyExpanded: serviceRecords.isNotEmpty,
      children: [
        if (serviceRecords.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'Brak wpisów w historii serwisowej',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Historia serwisowa zostanie wyświetlona po dodaniu pierwszych zapisów.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          )
        else
          ...serviceRecords.asMap().entries.map((entry) {
            final index = entry.key;
            final record = entry.value;
            final isLast = index == serviceRecords.length - 1;
            
            return Column(
              children: [
                _buildServiceRecordItem(record, vehicleFeatureColor),
                if (!isLast) const SizedBox(height: 12),
              ],
            );
          }).toList(),
      ],
    );
  }

  Widget _buildServiceRecordItem(ServiceRecord record, Color featureColor) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: featureColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.build,
            size: 20,
            color: featureColor,
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: featureColor),
            const SizedBox(width: 8),
            Text(
              record.date,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.speed, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                'Przebieg: ${record.mileage} km',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description, size: 16, color: featureColor),
                    const SizedBox(width: 8),
                    const Text(
                      'Opis serwisu:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    record.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Utworzono: ${_formatDate(DateTime.parse(record.createdAt))}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(VehicleState state) {
    if (state is VehicleInitial || state is VehicleLoading) {
      return const LoadingIndicator();
    }

    if (state is VehicleError) {
      return ErrorStateWidget(
        message: state.message,
        onRetry: () {
          _loadVehicleDetails();
          _loadServiceRecords();
        },
      );
    }

    if (state is VehicleDetailsLoaded) {
      final vehicle = state.vehicle;
      final serviceRecords = state is VehicleDetailsWithRecordsLoaded 
          ? state.serviceRecords 
          : <ServiceRecord>[];

      return _buildContent(context, vehicle, serviceRecords);
    }

    return EmptyStateWidget(
      icon: Icons.car_crash,
      message: 'Nie znaleziono pojazdu o podanym ID lub został usunięty.',
      actionButtonText: 'Powrót do listy pojazdów',
      onActionPressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Szczegóły Pojazdu',
        feature: 'vehicles',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed(
                VehicleEditScreen.routeName,
                arguments: {
                  'workshopId': widget.workshopId,
                  'vehicleId': widget.vehicleId,
                },
              ).then((_) {
                _loadVehicleDetails();
                _loadServiceRecords();
              });
            },
            tooltip: 'Edytuj pojazd',
          ),
        ],
      ),
      body: PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          if (didPop) {
            context.read<VehicleBloc>()
              ..add(ResetVehicleStateEvent())
              ..add(LoadVehiclesEvent(
                workshopId: widget.workshopId,
              ));
          }
        },
        child: BlocConsumer<VehicleBloc, VehicleState>(
          listener: (context, state) {
            if (state is VehicleError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) => _buildBody(state),
        ),
      ),
    );
  }
}
