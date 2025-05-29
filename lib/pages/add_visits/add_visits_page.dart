import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:visits_tracker/controllers/add_visits/add_visit_bloc.dart';
import 'package:visits_tracker/controllers/add_visits/add_visit_event.dart';
import 'package:visits_tracker/controllers/add_visits/add_visit_state.dart';
import 'package:visits_tracker/models/activity.dart';
import 'package:visits_tracker/models/customer.dart';
import 'package:visits_tracker/models/visit.dart';
import 'package:visits_tracker/services/activities_service.dart';
import 'package:visits_tracker/services/visits_service.dart';
import 'package:visits_tracker/utils/failure.dart';

class AddVisitPage extends StatefulWidget {

  @override
  State<AddVisitPage> createState() => _AddVisitPageState();
}

class _AddVisitPageState extends State<AddVisitPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController locationController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Data
  List<Customer> customers = [];
  List<Activity> activities = [];

  // Selections
  int? selectedCustomerId;
  DateTime? selectedDateTime;
  String selectedStatus = 'Pending';
  Set<int> selectedActivityIds = {};

  bool isLoadingCustomers = true;
  bool isLoadingActivities = true;

  final visitsRepository = Get.find<VisitsService>();
  final activitiesRepository = Get.find<ActivitiesService>();

  @override
  void initState() {
    super.initState();
    loadCustomers();
    loadActivities();
  }

  Future<void> loadCustomers() async {
    final Either<Failure, List<Customer>> result =
        await visitsRepository.fetchCustomers();
    result.fold((failure) => Get.snackbar('Error', failure.message), (data) {
      setState(() {
        customers = data;
        isLoadingCustomers = false;
      });
    });
  }

  Future<void> loadActivities() async {
    final Either<Failure, List<Activity>> result =
        await activitiesRepository.fetchActivities();
    result.fold((failure) => Get.snackbar('Error', failure.message), (data) {
      setState(() {
        activities = data;
        isLoadingActivities = false;
      });
    });
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate() ||
        selectedCustomerId == null ||
        selectedDateTime == null) {
      Get.snackbar('Invalid Input', 'Please complete all required fields');
      return;
    }

    final visit = Visit(
      id: 0,
      customerId: selectedCustomerId!,
      visitDate: selectedDateTime ?? DateTime.now(),
      status: selectedStatus,
      location: locationController.text.trim(),
      notes: notesController.text.trim(),
      activitiesDone: selectedActivityIds.toList(),
      createdAt: DateTime.now(),
    );

    context.read<AddVisitBloc>().add(SubmitVisit(visit));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Visit')),
      body: BlocConsumer<AddVisitBloc, AddVisitState>(
        listener: (context, state) {
          if (state is AddVisitSuccess) {
            Get.back();
            Get.snackbar('Success', 'Visit added successfully');
          } else if (state is AddVisitError) {
            Get.snackbar('Error', state.message);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                isLoadingCustomers || isLoadingActivities
                    ? const Center(child: CircularProgressIndicator())
                    : Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          DropdownButtonFormField<int>(
                            value: selectedCustomerId,
                            decoration: const InputDecoration(
                              labelText: 'Customer',
                            ),
                            items:
                                customers
                                    .map(
                                      (c) => DropdownMenuItem<int>(
                                        value: c.id,
                                        child: Text(c.name),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (value) =>
                                    setState(() => selectedCustomerId = value),
                            validator:
                                (value) => value == null ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: locationController,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Required'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            title: Text(
                              selectedDateTime == null
                                  ? 'Pick Visit Date & Time'
                                  : selectedDateTime.toString(),
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: _pickDateTime,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: selectedStatus,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                            ),
                            items:
                                ['Pending', 'Completed', 'Cancelled']
                                    .map(
                                      (status) => DropdownMenuItem<String>(
                                        value: status,
                                        child: Text(status),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (value) =>
                                    setState(() => selectedStatus = value!),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Activities Done:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children:
                                activities.map((activity) {
                                  final selected = selectedActivityIds.contains(
                                    activity.id,
                                  );
                                  return FilterChip(
                                    label: Text(activity.description),
                                    selected: selected,
                                    onSelected: (bool value) {
                                      setState(() {
                                        if (value) {
                                          selectedActivityIds.add(activity.id);
                                        } else {
                                          selectedActivityIds.remove(
                                            activity.id,
                                          );
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed:
                                state is AddVisitLoading ? null : _submit,
                            child:
                                state is AddVisitLoading
                                    ? const CircularProgressIndicator()
                                    : const Text('Submit'),
                          ),
                        ],
                      ),
                    ),
          );
        },
      ),
    );
  }
}
