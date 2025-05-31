import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visits_tracker/pages/home/visit_card.dart';
import 'package:visits_tracker/routes/app_routes.dart';
import '../../controllers/visits/visits_bloc.dart';
import '../../controllers/visits/visits_events.dart';
import '../../controllers/visits/visits_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Visits Tracker"), centerTitle: true),
      body: BlocConsumer<VisitsBloc, VisitsState>(
        listener: (context, state) {
          if (state is DeleteVisitSuccess) {
            context.read<VisitsBloc>().add(FetchVisits());
          }
        },
        builder: (context, state) {
          if (state is VisitsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VisitsLoaded) {
            final visitsToDisplay = state.finalDisplayedVisits;

            if (_searchController.text != state.searchQuery) {
              _searchController.text = state.searchQuery;
              _searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: _searchController.text.length),
              );
            }

            return Column(
              children: [
                _buildStatsGrid(state),
                _buildSearchField(state.searchQuery),
                Expanded(
                  child:
                      visitsToDisplay.isEmpty
                          ? const Center(
                            child: Text(
                              "No visits found for this filter/search.",
                            ),
                          )
                          : ListView.builder(
                            itemCount: visitsToDisplay.length,
                            itemBuilder: (context, index) {
                              final visit = visitsToDisplay[index];
                              return VisitCard(
                                visit: visit,
                                onTap: () {
                                  Get.toNamed(
                                    AppRoutes.visitDetail,
                                    arguments: visit,
                                  );
                                },
                              );
                            },
                          ),
                ),
              ],
            );
          } else if (state is VisitsError) {
            return Center(child: Text(state.message));
          }
          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoutes.addVisits);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsGrid(VisitsLoaded state) {
    final filters = [
      {
        'label': 'All',
        'count': state.totalVisitsStat,
      },
      {'label': 'Completed', 'count': state.totalCompletedStat},
      {'label': 'Pending', 'count': state.totalPendingStat},
      {'label': 'Cancelled', 'count': state.totalCancelledStat},
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.5,
        children:
            filters.map((f) {
              final String currentFilterLabel = f['label']!.toString();
              return GestureDetector(
                onTap: () {
                  context.read<VisitsBloc>().add(
                    FilterVisits(
                      status: currentFilterLabel,
                      searchQuery:
                          state
                              .searchQuery,
                    ),
                  );
                },
                child: Card(
                  color:
                      state.selectedStatus == currentFilterLabel
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                  elevation: 2,
                  child: Center(
                    child: Text(
                      "${f['label']}: ${f['count']}",
                      style: TextStyle(
                        color:
                            state.selectedStatus == currentFilterLabel
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSearchField(String currentSearchQuery) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Search by note or customer',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        onChanged: (value) {
          context.read<VisitsBloc>().add(
            FilterVisits(
              status:
                  (context.read<VisitsBloc>().state as VisitsLoaded)
                      .selectedStatus,
              searchQuery: value,
            ),
          );
        },
      ),
    );
  }
}
