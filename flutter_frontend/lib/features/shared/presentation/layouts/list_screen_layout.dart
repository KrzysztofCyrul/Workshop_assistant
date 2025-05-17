import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/error_state_widget.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/loading_indicator.dart';
import 'package:flutter_frontend/features/shared/presentation/widgets/search_field_widget.dart';
import 'package:flutter_frontend/core/widgets/custom_app_bar.dart';

class ListScreenLayout<B extends StateStreamable<S>, S> extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final String searchLabel;
  final String searchHint;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;
  final VoidCallback onAddNew;
  final String addNewLabel;
  final S state;
  final bool Function(S) isLoading;
  final bool Function(S) isError;
  final String Function(S) errorMessage;
  final Widget Function(S) buildContent;
  final FloatingActionButtonLocation floatingActionButtonLocation;
  final String? feature; // Feature identifier for theme styling
    const ListScreenLayout({
    super.key,
    required this.title,
    this.actions = const [],
    required this.searchLabel,
    required this.searchHint,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onAddNew,
    required this.addNewLabel,
    required this.state,
    required this.isLoading,
    required this.isError,
    required this.errorMessage,
    required this.buildContent,
    this.floatingActionButtonLocation = FloatingActionButtonLocation.endFloat,
    this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: CustomAppBar(
        title: title,
        feature: feature ?? 'home',
        actions: actions,
      ),
      body: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchFieldWidget(
                labelText: searchLabel,
                hintText: searchHint,
                onChanged: onSearchChanged,
                searchQuery: searchQuery,
              ),
            ),
            Expanded(
              child: _buildStateContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAddNew,
        icon: const Icon(Icons.add),
        label: Text(addNewLabel),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  Widget _buildStateContent() {
    if (isLoading(state)) {
      return const LoadingIndicator();
    }

    if (isError(state)) {
      return ErrorStateWidget(
        message: errorMessage(state),
        onRetry: onRefresh,
      );
    }

    return buildContent(state);
  }
}
