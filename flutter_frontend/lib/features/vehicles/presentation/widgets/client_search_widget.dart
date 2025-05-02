import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/clients/domain/entities/client.dart';
import 'package:flutter_frontend/features/clients/presentation/bloc/client_bloc.dart';
import 'package:flutter_frontend/features/clients/presentation/screens/add_client_screen.dart';
import 'package:flutter_frontend/features/clients/presentation/widgets/clients_list_widget.dart';

class ClientSearchWidget extends StatefulWidget {
  final Client? selectedClient;
  final ValueChanged<Client?> onChanged;
  final String? Function(Client?)? validator;
  final String workshopId;

  const ClientSearchWidget({
    super.key,
    this.selectedClient,
    required this.onChanged,
    this.validator,
    required this.workshopId,
  });

  @override
  State<ClientSearchWidget> createState() => _ClientSearchWidgetState();
}

class _ClientSearchWidgetState extends State<ClientSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  // String _selectedSegment = 'Wszystkie';  // Commented out segment-related code

  @override
  void initState() {
    super.initState();
    if (widget.selectedClient != null) {
      _searchController.text = 
          '${widget.selectedClient!.firstName} ${widget.selectedClient!.lastName}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<Client>(
      validator: widget.validator,
      initialValue: widget.selectedClient,
      builder: (FormFieldState<Client> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Wyszukaj klienta',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _isSearching = false;
                          });
                          widget.onChanged(null);
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          AddClientScreen.routeName,
                          arguments: {'workshopId': widget.workshopId},
                        );
                        if (result == true) {
                          context.read<ClientBloc>().add(
                                LoadClientsEvent(workshopId: widget.workshopId),
                              );
                        }
                      },
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                errorText: state.hasError ? state.errorText : null,
              ),
              onTap: () {
                setState(() => _isSearching = true);
              },
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
            if (_isSearching) ...[
              const SizedBox(height: 8),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: BlocBuilder<ClientBloc, ClientState>(
                  builder: (context, state) {
                    if (state is ClientsLoaded) {
                      return Column(
                        children: [
                          // Commented out segment chips
                          /*SizedBox(
                            height: 50,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final segment in ['Wszystkie', 'A', 'B', 'C', 'D'])
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ChoiceChip(
                                        label: Text(segment),
                                        selected: _selectedSegment == segment,
                                        onSelected: (selected) {
                                          setState(() => _selectedSegment = segment);
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),*/
                          Expanded(
                            child: ClientsListWidget(
                              clients: state.clients,
                              searchQuery: _searchQuery,
                              selectedSegment: 'Wszystkie', // Changed from _selectedSegment to 'Wszystkie'
                              onClientTap: (client) {
                                setState(() {
                                  _searchController.text = 
                                      '${client.firstName} ${client.lastName}';
                                  _isSearching = false;
                                });
                                widget.onChanged(client);
                              },
                            ),
                          ),
                        ],
                      );
                    } else if (state is ClientLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ClientError) {
                      return Center(child: Text(state.message));
                    }
                    return const Center(child: Text('Brak wyników'));
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}