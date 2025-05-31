import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:visits_tracker/controllers/visits/visits_bloc.dart';
import 'package:visits_tracker/controllers/visits/visits_events.dart';
import 'package:visits_tracker/routes/app_routes.dart';
import '../../models/visit.dart';

class VisitDetailPage extends StatefulWidget {
  const VisitDetailPage({super.key});

  @override
  State<VisitDetailPage> createState() => _VisitDetailPageState();
}

class _VisitDetailPageState extends State<VisitDetailPage> {
  late Visit visit;

  @override
  void initState() {
    super.initState();
    visit = Get.arguments as Visit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Detail'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Get.toNamed(
                AppRoutes.addVisits,
                arguments: visit,
              );
              if (result is Visit) {
                context.read<VisitsBloc>().add(FetchVisits());
                setState(() {
                  visit = result;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _confirmDelete(context, visit.id);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildDetailTile("Customer", visit.customerName),
            _buildDetailTile("Date", visit.visitDate.toLocal().toString()),
            _buildDetailTile("Status", visit.status),
            _buildDetailTile("Location", visit.location),
            _buildDetailTile(
              "Notes",
              visit.notes.isNotEmpty ? visit.notes : "No notes",
            ),
            _buildDetailTile(
              "Activities",
              visit.activityDescriptions != null &&
                      visit.activityDescriptions!.isNotEmpty
                  ? visit.activityDescriptions!.join(", ")
                  : "No activities recorded",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value),
          const Divider(),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int visitId) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Delete Visit"),
            content: const Text("Are you sure you want to delete this visit?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  context.read<VisitsBloc>().add(DeleteVisit(visitId));
                  Navigator.of(ctx).pop();
                  Get.back();
                  Get.snackbar("Success", "Visit deleted");
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
