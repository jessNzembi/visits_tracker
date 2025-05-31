import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visits_tracker/controllers/visits/visits_events.dart';
import 'package:visits_tracker/controllers/visits/visits_state.dart';
import 'package:visits_tracker/services/activities_service.dart';
import 'package:visits_tracker/services/customers_service.dart';
import 'package:visits_tracker/services/visits_service.dart';
import 'package:visits_tracker/models/visit.dart';

class VisitsBloc extends Bloc<VisitsEvent, VisitsState> {
  final VisitsService visitsRepository;
  final ActivitiesService activitiesRepository;
  final CustomersService customersRepository;
  


  List<Visit> _allVisits = [];

  VisitsBloc({
    required this.visitsRepository,
    required this.activitiesRepository,
    required this.customersRepository,
  }) : super(VisitsInitial()) {
    on<FetchVisits>(_onFetchVisits);
    on<FilterVisits>(_onFilterVisits);
    on<DeleteVisit>(_onDeleteVisit);
    on<SubmitVisit>(_onSubmitVisit);
    on<UpdateVisit>(_onUpdateVisit);
  }

  Future<void> _onFetchVisits(
    FetchVisits event,
    Emitter<VisitsState> emit,
  ) async {
    emit(VisitsLoading());

    final activityResult = await activitiesRepository.getActivitiesMap();
    final customerResult = await customersRepository.getCustomerMap();

    final visitsResult = await activityResult.fold(
      (failure) async => left(failure),
      (activityMap) async {
        return await customerResult.fold((failure) async => left(failure), (
          customerMap,
        ) async {
          return await visitsRepository.getVisits(
            activityMap: activityMap,
            customerMap: customerMap,
          );
        });
      },
    );


    visitsResult.fold((failure) => emit(VisitsError(failure.message)), (
      visits,
    ) {
      _allVisits = visits;
      emit(_buildLoadedState(_allVisits));
    });
  }

  void _onFilterVisits(FilterVisits event, Emitter<VisitsState> emit) {
    final currentState = state;
    if (currentState is VisitsLoaded) {
      List<Visit> filtered = _allVisits;

      // Filter by status
      if (event.status != 'All') {
        filtered = filtered.where((v) => v.status == event.status).toList();
      }

      // Filter by search query (customer name or note)
      if (event.searchQuery.isNotEmpty) {
        filtered =
            filtered.where((v) {
              final lower = event.searchQuery.toLowerCase();
              return (v.notes.toLowerCase().contains(lower)) ||
                  (v.customerName.toString().contains(lower));
            }).toList();
      }

      emit(_buildLoadedState(filtered));
    }
  }

  Future<void> _onDeleteVisit(
    DeleteVisit event,
    Emitter<VisitsState> emit,
  ) async {
    final result = await visitsRepository.deleteVisit(event.visitId);
    result.fold(
      (failure) => emit(VisitsError(failure.message)),
      (_) => add(FetchVisits()),
    );
  }

  Future<void> _onSubmitVisit(
    SubmitVisit event,
    Emitter<VisitsState> emit,
  ) async {
    emit(VisitsLoading());
    final result = await visitsRepository.addVisit(event.visit);
    result.fold(
      (failure) => emit(VisitsError(failure.message)),
      (_) => emit(AddVisitSuccess(event.visit)),
    );
  }

  Future<void> _onUpdateVisit(
    UpdateVisit event,
    Emitter<VisitsState> emit,
  ) async {
    emit(VisitsLoading());

    final activityResult = await activitiesRepository.getActivitiesMap();

    final customerResult = await customersRepository.getCustomerMap();

    final updateResult = await activityResult.fold(
      (failure) async => left(failure),
      (activityMap) async {
        return await customerResult.fold((failure) async => left(failure), (
          customerMap,
        ) async {
          return await visitsRepository.updateVisit(
            event.visit,
            activityMap,
            customerMap,
          );
        });
      },
    );

    updateResult.fold(
      (failure) => emit(VisitsError(failure.message)),
      (updatedVisit) => emit(AddVisitSuccess(updatedVisit)),
    );
  }




  VisitsLoaded _buildLoadedState(List<Visit> filtered) {
    int total = _allVisits.length;
    int completed = _allVisits.where((v) => v.status == 'Completed').length;
    int pending = _allVisits.where((v) => v.status == 'Pending').length;
    int cancelled = _allVisits.where((v) => v.status == 'Cancelled').length;

    return VisitsLoaded(
      visits: filtered,
      filteredVisits: filtered,
      totalVisits: total,
      totalCompleted: completed,
      totalPending: pending,
      totalCancelled: cancelled,
    );
  }
}
