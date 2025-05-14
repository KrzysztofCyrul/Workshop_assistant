part of 'quotation_bloc.dart';

sealed class QuotationState {
  const QuotationState();
}

class QuotationInitial extends QuotationState {}

class QuotationLoading extends QuotationState {}

class QuotationsLoaded extends QuotationState {
  final List<Quotation> quotations;

  QuotationsLoaded({required this.quotations});
}

class QuotationDetailsLoaded extends QuotationState {
  final Quotation quotation;

  QuotationDetailsLoaded({required this.quotation});
}

class QuotationOperationSuccessWithDetails extends QuotationState {
  final String message;
  final Quotation quotation;

  const QuotationOperationSuccessWithDetails({
    required this.message,
    required this.quotation,
  });
}

class QuotationAdded extends QuotationState {
  final String quotationId;

  QuotationAdded({required this.quotationId});
}

class QuotationPartsLoaded extends QuotationState {
  final List<QuotationPart> parts;

  QuotationPartsLoaded({required this.parts});
}

class QuotationOperationSuccess extends QuotationState {
  final String message;

  const QuotationOperationSuccess({required this.message});
}

class QuotationError extends QuotationState {
  final String message;

  QuotationError({required this.message});
}

class QuotationUnauthenticated extends QuotationState {
  const QuotationUnauthenticated();
}