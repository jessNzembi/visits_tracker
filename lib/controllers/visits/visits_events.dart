import 'package:visits_tracker/models/visit.dart';

abstract class VisitsEvent {}

class FetchVisits extends VisitsEvent {}

class FilterVisits extends VisitsEvent {
  final String status;
  final String searchQuery;

  FilterVisits({required this.status, required this.searchQuery});
}

class DeleteVisit extends VisitsEvent {
  final int visitId;

  DeleteVisit(this.visitId);
}

class SubmitVisit extends VisitsEvent {
  final Visit visit;

  SubmitVisit(this.visit);
}

class UpdateVisit extends VisitsEvent {
  final Visit visit;

  UpdateVisit(this.visit);
}


