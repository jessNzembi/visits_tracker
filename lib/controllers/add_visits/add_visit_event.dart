
import 'package:visits_tracker/models/visit.dart';

abstract class AddVisitEvent {}

class SubmitVisit extends AddVisitEvent {
  final Visit visit;

  SubmitVisit(this.visit);
}
