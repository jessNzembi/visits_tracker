import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:visits_tracker/controllers/visits/visits_bloc.dart';
import 'package:visits_tracker/controllers/visits/visits_events.dart';
import 'package:visits_tracker/routes/app_routes.dart';
import 'package:visits_tracker/services/activities_service.dart';
import 'package:visits_tracker/services/customers_service.dart';
import 'package:visits_tracker/services/visits_service.dart';

const String kBaseUrl = String.fromEnvironment('BASE_URL');
const String kApiKey = String.fromEnvironment('API_KEY');

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for sqflite
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  Get.put(VisitsService(baseUrl: kBaseUrl, apiKey: kApiKey));
  Get.put(ActivitiesService(baseUrl: kBaseUrl, apiKey: kApiKey));
  Get.put(CustomersService(baseUrl: kBaseUrl, apiKey: kApiKey));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => VisitsBloc(
            visitsRepository: Get.find<VisitsService>(),
            activitiesRepository: Get.find<ActivitiesService>(),
            customersRepository: Get.find<CustomersService>(),
          )..add(FetchVisits()),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
          brightness: Brightness.dark,
        ),
        initialRoute: AppRoutes.home,
        getPages: AppRoutes.routes,
      ),
    );
  }
}
