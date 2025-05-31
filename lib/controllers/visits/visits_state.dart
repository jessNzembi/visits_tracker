import 'package:equatable/equatable.dart';
import '../../models/visit.dart';

abstract class VisitsState extends Equatable {
  const VisitsState();

  @override
  List<Object> get props => [];
}

class VisitsInitial extends VisitsState {}

class VisitsLoading extends VisitsState {}


class VisitsLoaded extends VisitsState {
  final List<Visit> allVisits;
  final List<Visit> filteredVisitsByStatus;
  final List<Visit>
  filteredVisitsBySearch;
  final List<Visit>
  finalDisplayedVisits;

  // Statistics displayed on the cards.
  final int totalVisitsStat;
  final int totalCompletedStat;
  final int totalPendingStat;
  final int totalCancelledStat;

  final String selectedStatus;
  final String searchQuery;

  const VisitsLoaded({
    required this.allVisits,
    required this.filteredVisitsByStatus,
    required this.filteredVisitsBySearch,
    required this.finalDisplayedVisits,
    required this.totalVisitsStat,
    required this.totalCompletedStat,
    required this.totalPendingStat,
    required this.totalCancelledStat,
    required this.selectedStatus,
    required this.searchQuery,
  });

  VisitsLoaded copyWith({
    List<Visit>? allVisits,
    List<Visit>? filteredVisitsByStatus,
    List<Visit>? filteredVisitsBySearch,
    List<Visit>? finalDisplayedVisits,
    int? totalVisitsStat,
    int? totalCompletedStat,
    int? totalPendingStat,
    int? totalCancelledStat,
    String? selectedStatus,
    String? searchQuery,
  }) {
    return VisitsLoaded(
      allVisits: allVisits ?? this.allVisits,
      filteredVisitsByStatus:
          filteredVisitsByStatus ?? this.filteredVisitsByStatus,
      filteredVisitsBySearch:
          filteredVisitsBySearch ?? this.filteredVisitsBySearch,
      finalDisplayedVisits: finalDisplayedVisits ?? this.finalDisplayedVisits,
      totalVisitsStat: totalVisitsStat ?? this.totalVisitsStat,
      totalCompletedStat: totalCompletedStat ?? this.totalCompletedStat,
      totalPendingStat: totalPendingStat ?? this.totalPendingStat,
      totalCancelledStat: totalCancelledStat ?? this.totalCancelledStat,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object> get props => [
    allVisits,
    filteredVisitsByStatus,
    filteredVisitsBySearch,
    finalDisplayedVisits,
    totalVisitsStat,
    totalCompletedStat,
    totalPendingStat,
    totalCancelledStat,
    selectedStatus,
    searchQuery,
  ];
}

class AddVisitSuccess extends VisitsState {
  final Visit visit;

  const AddVisitSuccess(this.visit);
}

class DeleteVisitSuccess extends VisitsState {}

class VisitsError extends VisitsState {
  final String message;
  const VisitsError(this.message);
}
