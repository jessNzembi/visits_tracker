import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:visits_tracker/controllers/visits/visits_bloc.dart';
import 'package:visits_tracker/controllers/visits/visits_events.dart';
import 'package:visits_tracker/controllers/visits/visits_state.dart';
import 'package:visits_tracker/pages/home/add_visits_page.dart';
import 'package:visits_tracker/pages/home/home_page.dart';
import 'package:visits_tracker/pages/home/visit_detail_page.dart';

class AppRoutes {
  static const addVisits = '/addVisits';
  static const home = '/home';
  static const visitDetail = '/visitDetail';

  static List<GetPage> routes = [
    GetPage(
      name: home,
      page:
          () => BlocListener<VisitsBloc, VisitsState>(
            listener: (context, state) {
              if (state is DeleteVisitSuccess || state is AddVisitSuccess) {
                context.read<VisitsBloc>().add(FetchVisits());
              }
            },
            child: const HomePage(),
          ),
    ),
    GetPage(
      name: visitDetail,
      page:
          () =>
              const VisitDetailPage(),
    ),
    GetPage(
      name: addVisits,
      page: () => const AddVisitPage(),
    ),
  ];
}
