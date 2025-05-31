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

    visitsResult.fold((failure) => emit(VisitsError(failure.message)), 
    (
      visits,
    ) {
      String currentSelectedStatus = 'All';
      String currentSearchQuery = '';

      if (state is VisitsLoaded) {
        final previousState = state as VisitsLoaded;
        currentSelectedStatus = previousState.selectedStatus;
        currentSearchQuery = previousState.searchQuery;
      }

      // Calculate all necessary lists and stats
      _emitLoadedState(
        emit,
        allVisits: visits,
        selectedStatus: currentSelectedStatus,
        searchQuery: currentSearchQuery,
      );
    });
  }
 

  Future<void> _onFilterVisits(
    FilterVisits event,
    Emitter<VisitsState> emit,
  ) async {
    if (state is VisitsLoaded) {
      final currentState = state as VisitsLoaded;
      final newSelectedStatus = event.status;
      final newSearchQuery = event.searchQuery;

      // Re-calculate all lists and stats based on new filter/search
      _emitLoadedState(
        emit,
        allVisits: currentState.allVisits,
        selectedStatus: newSelectedStatus,
        searchQuery: newSearchQuery,
      );
    }
  }

  // Centralized method to build and emit VisitsLoaded state
  void _emitLoadedState(
    Emitter<VisitsState> emit, {
    required List<Visit> allVisits,
    required String selectedStatus,
    required String searchQuery,
  }) {
    //Filter by status
    final List<Visit> filteredVisitsByStatus = _applyStatusFilter(
      allVisits,
      selectedStatus,
    );

    // Filter by search query
    final List<Visit> filteredVisitsBySearch = _applySearchFilter(
      allVisits,
      searchQuery,
    );

    final List<Visit> finalDisplayedVisits = _applyStatusFilter(
      filteredVisitsBySearch,
      selectedStatus,
    );

    //Calculate statistics based on:
    //    - If search is active: filteredVisitsBySearch
    //    - If no search: allVisits
    final List<Visit> listForStats =
        searchQuery.isNotEmpty ? filteredVisitsBySearch : allVisits;

    final int totalVisitsStat = listForStats.length;
    final int totalCompletedStat =
        listForStats.where((v) => v.status == 'Completed').length;
    final int totalPendingStat =
        listForStats.where((v) => v.status == 'Pending').length;
    final int totalCancelledStat =
        listForStats.where((v) => v.status == 'Cancelled').length;

    emit(
      VisitsLoaded(
        allVisits: allVisits,
        filteredVisitsByStatus: filteredVisitsByStatus,
        filteredVisitsBySearch: filteredVisitsBySearch,
        finalDisplayedVisits: finalDisplayedVisits,
        totalVisitsStat: totalVisitsStat,
        totalCompletedStat: totalCompletedStat,
        totalPendingStat: totalPendingStat,
        totalCancelledStat: totalCancelledStat,
        selectedStatus: selectedStatus,
        searchQuery: searchQuery,
      ),
    );
  }

  // Helper for status filtering
  List<Visit> _applyStatusFilter(List<Visit> visitsToFilter, String status) {
    if (status == 'All') {
      return List.from(visitsToFilter);
    }
    return visitsToFilter.where((v) => v.status == status).toList();
  }

  // Helper for search filtering
  List<Visit> _applySearchFilter(List<Visit> visitsToFilter, String query) {
    if (query.isEmpty) {
      return List.from(visitsToFilter);
    }
    final lowerQuery = query.toLowerCase();
    return visitsToFilter.where((v) {
      return (v.notes.toLowerCase().contains(lowerQuery)) ||
          (v.customerName.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  Future<void> _onDeleteVisit(
    DeleteVisit event,
    Emitter<VisitsState> emit,
  ) async {
    final result = await visitsRepository.deleteVisit(event.visitId);
    result.fold(
      (failure) => emit(VisitsError(failure.message)),
      (_) => emit(DeleteVisitSuccess()),
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

  // VisitsLoaded _buildLoadedState(List<Visit> filtered) {
  //   int total = _allVisits.length;
  //   int completed = _allVisits.where((v) => v.status == 'Completed').length;
  //   int pending = _allVisits.where((v) => v.status == 'Pending').length;
  //   int cancelled = _allVisits.where((v) => v.status == 'Cancelled').length;

  //   return VisitsLoaded(
  //     visits: filtered,
  //     filteredVisits: filtered,
  //     totalVisits: total,
  //     totalCompleted: completed,
  //     totalPending: pending,
  //     totalCancelled: cancelled,
  //   );
  // }
}
