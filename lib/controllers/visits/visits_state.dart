import '../../models/visit.dart';

abstract class VisitsState {}

class VisitsInitial extends VisitsState {}

class VisitsLoading extends VisitsState {}

class VisitsLoaded extends VisitsState {
  final List<Visit> visits;
  final List<Visit> filteredVisits;
  final int totalVisits;
  final int totalCompleted;
  final int totalPending;
  final int totalCancelled;

  VisitsLoaded({
    required this.visits,
    required this.filteredVisits,
    required this.totalVisits,
    required this.totalCompleted,
    required this.totalPending,
    required this.totalCancelled,
  });
}

class AddVisitSuccess extends VisitsState {
  final Visit visit;

  AddVisitSuccess(this.visit);
}

class VisitsError extends VisitsState {
  final String message;
  VisitsError(this.message);
}
