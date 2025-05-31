import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:visits_tracker/controllers/visits/visits_bloc.dart';
import 'package:visits_tracker/controllers/visits/visits_events.dart';
import 'package:visits_tracker/controllers/visits/visits_state.dart';
import 'package:visits_tracker/models/activity.dart';
import 'package:visits_tracker/models/customer.dart';
import 'package:visits_tracker/models/visit.dart';
import 'package:visits_tracker/services/activities_service.dart';
import 'package:visits_tracker/services/customers_service.dart';
import 'package:visits_tracker/services/visits_service.dart';
import 'package:visits_tracker/utils/failure.dart';

class AddVisitPage extends StatefulWidget {
  const AddVisitPage({super.key});


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

  final visitsService = Get.find<VisitsService>();
  final activitiesService = Get.find<ActivitiesService>();
  final customersService = Get.find<CustomersService>();

  Visit? editingVisit;

  @override
  void initState() {
    super.initState();
    editingVisit = Get.arguments as Visit?;
    loadCustomers();
    loadActivities();
  }

  Future<void> loadCustomers() async {
    final Either<Failure, List<Customer>> result =
        await customersService.fetchCustomers();
    result.fold(
      (failure) {
        Get.snackbar('Error', failure.message);
      },
      (data) {
        setState(() {
          customers = data;
          isLoadingCustomers = false;

          if (editingVisit != null) {
            selectedCustomerId = editingVisit!.customerId;
            locationController.text = editingVisit!.location;
            notesController.text = editingVisit!.notes;
            selectedDateTime = editingVisit!.visitDate;
            selectedStatus = editingVisit!.status;
            selectedActivityIds = editingVisit!.activitiesDone.toSet();
          }
        });
      },
    );
  }


  Future<void> loadActivities() async {
    final Either<Failure, List<Activity>> result =
        await activitiesService.fetchActivities();
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
      id: editingVisit?.id ?? 0,
      customerId: selectedCustomerId!,
      visitDate: selectedDateTime!,
      status: selectedStatus,
      location: locationController.text.trim(),
      notes: notesController.text.trim(),
      activitiesDone: selectedActivityIds.toList(),
      createdAt: editingVisit?.createdAt ?? DateTime.now(),
    );

    if (editingVisit == null) {
      context.read<VisitsBloc>().add(SubmitVisit(visit));
    } else {
      context.read<VisitsBloc>().add(
        UpdateVisit(visit),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editingVisit == null ? 'Add Visit' : 'Edit Visit'),
        centerTitle: true,
      ),
      body: BlocConsumer<VisitsBloc, VisitsState>(
        listener: (context, state) {
          if (state is AddVisitSuccess) {
            Get.back(result: state.visit);
            Get.snackbar('Success', 'Visit added successfully');
          } else if (state is VisitsError) {
            Get.snackbar('Error', state.message);
            print(state.message);
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
                            decoration: InputDecoration(
                              labelText: 'Customer',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              )
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
                            decoration: InputDecoration(
                              labelText: 'Location',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
                            decoration: InputDecoration(
                              labelText: 'Notes',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              )
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
                            decoration: InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              )
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
                                state is VisitsLoading ? null : _submit,
                            child:
                                state is VisitsLoading
                                    ? const CircularProgressIndicator()
                                    : Text(
                                      editingVisit == null
                                          ? 'Submit'
                                          : 'Update',
                                    ),
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
