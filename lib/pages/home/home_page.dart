import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visits_tracker/models/visit.dart';
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
  String selectedStatus = 'All';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Visits Tracker"), centerTitle: true,),
      body: BlocBuilder<VisitsBloc, VisitsState>(
        builder: (context, state) {
          if (state is VisitsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VisitsLoaded) {
            final visits = state.filteredVisits;
            return Column(
              children: [
                _buildStatsGrid(state),
                _buildSearchField(),
                Expanded(
                  child: ListView.builder(
                    itemCount: visits.length,
                    itemBuilder: (context, index) {
                      final visit = visits[index];
                      return VisitCard(visit: visit, onTap: () {
                          Get.toNamed(AppRoutes.visitDetail, arguments: visit);
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
        onPressed: () async {
          final result = await Get.toNamed(AppRoutes.addVisits);
          if (result == true || result is Visit) {
            // Dispatch refresh event
            context.read<VisitsBloc>().add(FetchVisits());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsGrid(VisitsLoaded state) {
    final filters = [
      {'label': 'All', 'count': state.totalVisits},
      {'label': 'Completed', 'count': state.totalCompleted},
      {'label': 'Pending', 'count': state.totalPending},
      {'label': 'Cancelled', 'count': state.totalCancelled},
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
              return GestureDetector(
                onTap: () {
                  setState(() => selectedStatus = f['label']!.toString());
                  context.read<VisitsBloc>().add(
                    FilterVisits(
                      status: selectedStatus,
                      searchQuery: searchQuery,
                    ),
                  );
                },
                child: Card(
                  color:
                      selectedStatus == f['label']
                          ? Colors.green
                          : Colors.white,
                  elevation: 2,
                  child: Center(child: Text("${f['label']}: ${f['count']}", style: TextStyle(color: Colors.white),)),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Search by note or customer',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        ),
        onChanged: (value) {
          setState(() => searchQuery = value);
          context.read<VisitsBloc>().add(
            FilterVisits(status: selectedStatus, searchQuery: searchQuery),
          );
        },
      ),
    );
  }
}
