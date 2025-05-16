// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_frontend/features/quotations/domain/usecases/get_quotations.dart';
import 'package:flutter_frontend/features/quotations/domain/usecases/get_quotation_details.dart';
import 'package:flutter_frontend/features/quotations/domain/usecases/create_quotation.dart';
import 'package:flutter_frontend/features/quotations/domain/usecases/update_quotation.dart';
import 'package:flutter_frontend/features/quotations/domain/usecases/delete_quotation.dart';
import 'package:flutter_frontend/features/quotations/domain/usecases/get_quotation_parts.dart';
import 'package:flutter_frontend/features/quotations/domain/usecases/create_quotation_part.dart';
import 'package:flutter_frontend/features/quotations/domain/usecases/update_quotation_part.dart';
import 'package:flutter_frontend/features/quotations/domain/usecases/delete_quotation_part.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation.dart';
import 'package:flutter_frontend/features/quotations/domain/entities/quotation_part.dart';

part 'quotation_event.dart';
part 'quotation_state.dart';

class AuthException implements Exception {}

class QuotationBloc extends Bloc<QuotationEvent, QuotationState> {
  final GetQuotations getQuotations;
  final GetQuotationDetails getQuotationDetails;
  final CreateQuotation createQuotation;
  final UpdateQuotation updateQuotation;
  final DeleteQuotation deleteQuotation;
  final GetQuotationParts getQuotationParts;
  final CreateQuotationPart createQuotationPart;
  final UpdateQuotationPart updateQuotationPart;
  final DeleteQuotationPart deleteQuotationPart;
  final AuthBloc authBloc;

  late final StreamSubscription<AuthState> _authSubscription;

  QuotationBloc({
    required this.getQuotations,
    required this.getQuotationDetails,
    required this.createQuotation,
    required this.updateQuotation,
    required this.deleteQuotation,
    required this.getQuotationParts,
    required this.createQuotationPart,
    required this.updateQuotationPart,
    required this.deleteQuotationPart,
    required this.authBloc,
  }) : super(QuotationInitial()) {
    // Event handlers
    on<LoadQuotationsEvent>(_onLoadQuotations);
    on<LoadQuotationDetailsEvent>(_onLoadQuotationDetails);
    on<AddQuotationEvent>(_onAddQuotation);
    on<UpdateQuotationEvent>(_onUpdateQuotation);
    on<DeleteQuotationEvent>(_onDeleteQuotation);
    on<LoadQuotationPartsEvent>(_onLoadQuotationParts);
    on<AddQuotationPartEvent>(_onAddQuotationPart);
    on<UpdateQuotationPartEvent>(_onUpdateQuotationPart);
    on<DeleteQuotationPartEvent>(_onDeleteQuotationPart);
    on<ResetQuotationStateEvent>(_onResetState);
    on<QuotationLogoutEvent>(_onLogout);

    // Auth state listener
    _authSubscription = authBloc.stream.listen((authState) {
      if (authState is Unauthenticated) {
        add(QuotationLogoutEvent());
      }
    });
  }

  Future<void> _onLoadQuotations(
    LoadQuotationsEvent event,
    Emitter<QuotationState> emit,
  ) async {
    emit(QuotationLoading());
    try {
      final result = await getQuotations.execute(event.workshopId);
      result.fold(
        (failure) {
          if (failure.message.contains('unauthorized') || failure.message.contains('Unauthorized')) {
            emit(const QuotationUnauthenticated());
          } else {
            emit(QuotationError(message: failure.message));
          }
        },
        (quotations) => emit(QuotationsLoaded(quotations: quotations)),
      );
    } on AuthException {
      emit(const QuotationUnauthenticated());
    } catch (e) {
      emit(QuotationError(message: e.toString()));
    }
  }

  Future<void> _onLoadQuotationDetails(
    LoadQuotationDetailsEvent event,
    Emitter<QuotationState> emit,
  ) async {
    emit(QuotationLoading());
    try {
      final result = await getQuotationDetails.execute(
        event.workshopId,
        event.quotationId,
      );
      result.fold(
        (failure) {
          if (failure.message.contains('unauthorized') || failure.message.contains('Unauthorized')) {
            emit(const QuotationUnauthenticated());
          } else {
            emit(QuotationError(message: failure.message));
          }
        },
        (quotation) {
          // Sortuj części według daty utworzenia (rosnąco)
          final sortedParts = [...quotation.parts];
          sortedParts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          
          emit(QuotationDetailsLoaded(quotation: quotation.copyWith(parts: sortedParts)));
        },
      );
    } catch (e) {
      // error handling...
    }
  }

  Future<void> _onAddQuotation(
    AddQuotationEvent event,
    Emitter<QuotationState> emit,
  ) async {
    emit(QuotationLoading());
    try {
      final result = await createQuotation.execute(
        workshopId: event.workshopId,
        clientId: event.clientId,
        vehicleId: event.vehicleId,
        totalCost: event.totalCost,
        notes: event.notes,
        date: event.date,
      );
      result.fold(
        (failure) {
          if (failure.message.contains('unauthorized') || failure.message.contains('Unauthorized')) {
            emit(const QuotationUnauthenticated());
          } else {
            emit(QuotationError(message: failure.message));
          }
        },
        (quotationId) {
          emit(QuotationAdded(quotationId: quotationId));
          emit(const QuotationOperationSuccess(message: 'Wycena dodana pomyślnie'));
        },
      );
    } on AuthException {
      emit(const QuotationUnauthenticated());
    } catch (e) {
      emit(QuotationError(message: 'Błąd podczas dodawania wyceny: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateQuotation(
    UpdateQuotationEvent event,
    Emitter<QuotationState> emit,
  ) async {
    emit(QuotationLoading());
    try {
      final result = await updateQuotation.execute(
        workshopId: event.workshopId,
        quotationId: event.quotationId,
        totalCost: event.totalCost,
      );
      result.fold(
        (failure) {
          if (failure.message.contains('unauthorized') || failure.message.contains('Unauthorized')) {
            emit(const QuotationUnauthenticated());
          } else {
            emit(QuotationError(message: failure.message));
          }
        },
        (_) {
          emit(const QuotationOperationSuccess(message: 'Wycena zaktualizowana pomyślnie'));
        },
      );
    } on AuthException {
      emit(const QuotationUnauthenticated());
    } catch (e) {
      emit(QuotationError(message: 'Błąd podczas aktualizacji wyceny: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteQuotation(
    DeleteQuotationEvent event,
    Emitter<QuotationState> emit,
  ) async {
    emit(QuotationLoading());
    try {
      final result = await deleteQuotation.execute(event.workshopId, event.quotationId);
      result.fold(
        (failure) {
          if (failure.message.contains('unauthorized') || failure.message.contains('Unauthorized')) {
            emit(const QuotationUnauthenticated());
          } else {
            emit(QuotationError(message: failure.message));
          }
        },
        (_) {
          emit(const QuotationOperationSuccess(message: 'Wycena usunięta pomyślnie'));
        },
      );
    } on AuthException {
      emit(const QuotationUnauthenticated());
    } catch (e) {
      emit(QuotationError(message: 'Błąd podczas usuwania wyceny: ${e.toString()}'));
    }
  }

  Future<void> _onLoadQuotationParts(
    LoadQuotationPartsEvent event,
    Emitter<QuotationState> emit,
  ) async {
    emit(QuotationLoading());
    try {
      final result = await getQuotationParts.execute(
        workshopId: event.workshopId,
        quotationId: event.quotationId,
      );
      result.fold(
        (failure) {
          if (failure.message.contains('unauthorized') || failure.message.contains('Unauthorized')) {
            emit(const QuotationUnauthenticated());
          } else {
            emit(QuotationError(message: failure.message));
          }
        },
        (parts) => emit(QuotationPartsLoaded(parts: parts)),
      );
    } on AuthException {
      emit(const QuotationUnauthenticated());
    } catch (e) {
      emit(QuotationError(message: e.toString()));
    }
  }

  Future<void> _onAddQuotationPart(
    AddQuotationPartEvent event,
    Emitter<QuotationState> emit,
  ) async {
    final currentState = state;
    if (currentState is QuotationDetailsLoaded || currentState is QuotationOperationSuccessWithDetails) {
      final currentQuotation = currentState is QuotationDetailsLoaded 
          ? currentState.quotation 
          : (currentState as QuotationOperationSuccessWithDetails).quotation;

      try {
        // Tworzenie tymczasowej części z unikalnym ID
        final now = DateTime.now();
        final tempPart = QuotationPart(
          id: 'temp_${now.millisecondsSinceEpoch}',
          quotationId: currentQuotation.id,
          name: event.name,
          description: event.description ?? '',
          quantity: event.quantity,
          costPart: event.costPart,
          costService: event.costService,
          buyCostPart: event.buyCostPart,
          createdAt: now,
          updatedAt: now,
        );

        // Dodaj tymczasową część do listy i emituj zaktualizowany stan (optymistyczna aktualizacja)
        final updatedParts = [...currentQuotation.parts, tempPart];
        
        // Sortuj części według daty utworzenia (rosnąco)
        updatedParts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        
        // Emituj zaktualizowany stan
        emit(QuotationDetailsLoaded(
          quotation: currentQuotation.copyWith(parts: updatedParts)
        ));

        // Wykonaj właściwe żądanie API
        final result = await createQuotationPart.execute(
          workshopId: event.workshopId,
          quotationId: event.quotationId,
          name: event.name,
          description: event.description,
          quantity: event.quantity,
          costPart: event.costPart,
          costService: event.costService,
          buyCostPart: event.buyCostPart,
        );

        // Obsłuż wynik żądania API
        if (emit.isDone) return; // Sprawdź, czy można nadal emitować stany
        
        result.fold(
          (failure) {
            if (failure.message.contains('unauthorized') || failure.message.contains('Unauthorized')) {
              emit(const QuotationUnauthenticated());
            } else {
              // W przypadku błędu - przywróć oryginalny stan
              emit(QuotationDetailsLoaded(quotation: currentQuotation));
              emit(QuotationError(message: failure.message));
            }
          },
          (newPart) {
            // Po sukcesie pokaż komunikat, ale nie odświeżaj całego ekranu
            emit(QuotationOperationSuccess(message: 'Część wyceny dodana pomyślnie'));
          },
        );
      } on AuthException {
        if (emit.isDone) return;
        emit(const QuotationUnauthenticated());
      } catch (e) {
        if (emit.isDone) return;
        // W przypadku błędu - przywróć oryginalny stan
        emit(QuotationDetailsLoaded(quotation: currentQuotation));
        emit(QuotationError(message: 'Błąd dodawania części wyceny: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateQuotationPart(
    UpdateQuotationPartEvent event,
    Emitter<QuotationState> emit,
  ) async {
    final currentState = state;
    if (currentState is QuotationDetailsLoaded || currentState is QuotationOperationSuccessWithDetails) {
      final currentQuotation = currentState is QuotationDetailsLoaded ? currentState.quotation : (currentState as QuotationOperationSuccessWithDetails).quotation;
      
      try {
        // Zachowujemy oryginalne pozycje części
        final originalParts = [...currentQuotation.parts];
        
        // Update the part in the current state immediately
        final updatedParts = currentQuotation.parts.map((part) {
          if (part.id == event.partId) {
            return QuotationPart(
              id: part.id,
              quotationId: currentQuotation.id,
              name: event.name,
              description: event.description ?? part.description,
              quantity: event.quantity,
              costPart: event.costPart,
              costService: event.costService,
              buyCostPart: event.buyCostPart,
              createdAt: part.createdAt,
              updatedAt: DateTime.now(),
            );
          }
          return part;
        }).toList();
        
        // Zachowujemy oryginalną kolejność części
        updatedParts.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        
        // Emit intermediate state with locally updated data
        emit(QuotationDetailsLoaded(
          quotation: currentQuotation.copyWith(parts: updatedParts)
        ));

        await updateQuotationPart.execute(
          workshopId: event.workshopId,
          quotationId: event.quotationId,
          partId: event.partId,
          name: event.name,
          description: event.description,
          quantity: event.quantity,
          costPart: event.costPart,
          costService: event.costService,
          buyCostPart: event.buyCostPart,
        );

        // Get updated quotation details
        final updatedQuotation = await getQuotationDetails.execute(
          event.workshopId,
          event.quotationId,
        );
        
        updatedQuotation.fold(
          (failure) {
            if (failure.message.contains('unauthorized') || 
                failure.message.contains('Unauthorized')) {
              emit(const QuotationUnauthenticated());
            } else {
              emit(QuotationError(message: failure.message));
            }
          },
          (quotation) {
            // Posortuj nowo pobrane części zachowując oryginalną kolejność
            final sortedParts = [...quotation.parts];
            sortedParts.sort((a, b) {
              final originalIndexA = originalParts.indexWhere((p) => p.id == a.id);
              final originalIndexB = originalParts.indexWhere((p) => p.id == b.id);
              if (originalIndexA == -1) return 1;  // Nowe elementy na koniec
              if (originalIndexB == -1) return -1; // Nowe elementy na koniec
              return originalIndexA.compareTo(originalIndexB);
            });
            
            // Emituj stan z posortowanymi częściami
            emit(QuotationOperationSuccessWithDetails(
              message: 'Część zaktualizowana pomyślnie',
              quotation: quotation.copyWith(parts: sortedParts),
            ));
          },
        );
      } on AuthException {
        emit(const QuotationUnauthenticated());
      } catch (e) {
        // Revert to original state on error
        emit(QuotationDetailsLoaded(quotation: currentQuotation));
        emit(QuotationError(message: 'Błąd aktualizacji części: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeleteQuotationPart(
    DeleteQuotationPartEvent event,
    Emitter<QuotationState> emit,
  ) async {
    final currentState = state;
    if (currentState is QuotationDetailsLoaded || currentState is QuotationOperationSuccessWithDetails) {
      final currentQuotation = currentState is QuotationDetailsLoaded 
          ? currentState.quotation 
          : (currentState as QuotationOperationSuccessWithDetails).quotation;

      try {
        // Update state immediately by removing the part (optimistic update)
        final updatedParts = currentQuotation.parts.where((part) => part.id != event.partId).toList();
        
        // Sortuj części według daty utworzenia (rosnąco)
        updatedParts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        
        emit(QuotationDetailsLoaded(quotation: currentQuotation.copyWith(parts: updatedParts)));

        // Then make API call
        await deleteQuotationPart.execute(
          workshopId: event.workshopId,
          quotationId: event.quotationId,
          partId: event.partId,
        );

        // Get updated quotation details
        final updatedQuotation = await getQuotationDetails.execute(
          event.workshopId,
          event.quotationId,
        );
        
        updatedQuotation.fold(
          (failure) {
            if (failure.message.contains('unauthorized') || failure.message.contains('Unauthorized')) {
              emit(const QuotationUnauthenticated());
            } else {
              emit(QuotationError(message: failure.message));
            }
          },
          (quotation) {
            // Sortuj części według daty utworzenia
            final sortedParts = [...quotation.parts];
            sortedParts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            
            emit(QuotationOperationSuccessWithDetails(
              message: 'Część usunięta pomyślnie',
              quotation: quotation.copyWith(parts: sortedParts),
            ));
          },
        );
      } on AuthException {
        emit(const QuotationUnauthenticated());
      } catch (e) {
        // Revert to original state on error
        emit(QuotationDetailsLoaded(quotation: currentQuotation));
        emit(QuotationError(message: 'Błąd usuwania części wyceny: ${e.toString()}'));
      }
    }
  }

  Future<void> _onResetState(
    ResetQuotationStateEvent event,
    Emitter<QuotationState> emit,
  ) async {
    emit(QuotationInitial());
  }

  Future<void> _onLogout(
    QuotationLogoutEvent event,
    Emitter<QuotationState> emit,
  ) async {
    emit(const QuotationUnauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
