
abstract class AddVisitState {}

class AddVisitInitial extends AddVisitState {}

class AddVisitLoading extends AddVisitState {}

class AddVisitSuccess extends AddVisitState {}

class AddVisitError extends AddVisitState {
  final String message;
  AddVisitError(this.message);
}
