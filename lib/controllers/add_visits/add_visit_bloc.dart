import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visits_tracker/controllers/add_visits/add_visit_event.dart';
import 'package:visits_tracker/controllers/add_visits/add_visit_state.dart';
import 'package:visits_tracker/services/visits_service.dart';

class AddVisitBloc extends Bloc<AddVisitEvent, AddVisitState> {
  final VisitsService visitsRepository;

  AddVisitBloc({required this.visitsRepository}) : super(AddVisitInitial()) {
    on<SubmitVisit>((event, emit) async {
      emit(AddVisitLoading());
      final result = await visitsRepository.addVisit(event.visit);
      result.fold(
        (failure) => emit(AddVisitError(failure.message)),
        (_) => emit(AddVisitSuccess()),
      );
    });
  }
}
