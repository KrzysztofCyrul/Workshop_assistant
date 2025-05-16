part of 'quotation_bloc.dart';

sealed class QuotationEvent {
  const QuotationEvent();
}

class LoadQuotationsEvent extends QuotationEvent {
  final String workshopId;

  const LoadQuotationsEvent({required this.workshopId});
}

class LoadQuotationDetailsEvent extends QuotationEvent {
  final String workshopId;
  final String quotationId;

  LoadQuotationDetailsEvent({
    required this.workshopId, 
    required this.quotationId
  });
}

class AddQuotationEvent extends QuotationEvent {
  final String workshopId;
  final String clientId;
  final String vehicleId;
  final double? totalCost;
  final String? notes;
  final DateTime? date;

  const AddQuotationEvent({
    required this.workshopId,
    required this.clientId,
    required this.vehicleId,
    this.totalCost,
    this.notes,
    this.date,
  });
}

class UpdateQuotationEvent extends QuotationEvent {
  final String workshopId;
  final String quotationId;
  final double? totalCost;

  UpdateQuotationEvent({
    required this.workshopId,
    required this.quotationId,
    this.totalCost,
  });
}

class DeleteQuotationEvent extends QuotationEvent {
  final String workshopId;
  final String quotationId;

  DeleteQuotationEvent({
    required this.workshopId, 
    required this.quotationId
  });
}

class LoadQuotationPartsEvent extends QuotationEvent {
  final String workshopId;
  final String quotationId;

  LoadQuotationPartsEvent({
    required this.workshopId, 
    required this.quotationId
  });
}

class AddQuotationPartEvent extends QuotationEvent {
  final String workshopId;
  final String quotationId;
  final String name;
  final String? description;
  final int quantity;
  final double costPart;
  final double costService;
  final double buyCostPart;

  AddQuotationPartEvent({
    required this.workshopId,
    required this.quotationId,
    required this.name,
    required this.description,
    required this.quantity,
    required this.costPart,
    required this.costService,
    required this.buyCostPart,
  });
}

class UpdateQuotationPartEvent extends QuotationEvent {
  final String workshopId;
  final String quotationId;
  final String partId;
  final String name;
  final String? description;
  final int quantity;
  final double costPart;
  final double costService;
  final double buyCostPart;

  UpdateQuotationPartEvent({
    required this.workshopId,
    required this.quotationId,
    required this.partId,
    required this.name,
    required this.description,
    required this.quantity,
    required this.costPart,
    required this.costService,
    required this.buyCostPart,
  });
}

class DeleteQuotationPartEvent extends QuotationEvent {
  final String workshopId;
  final String quotationId;
  final String partId;

  DeleteQuotationPartEvent({
    required this.workshopId,
    required this.quotationId,
    required this.partId,
  });
}

class ResetQuotationStateEvent extends QuotationEvent {}

class QuotationLogoutEvent extends QuotationEvent {}