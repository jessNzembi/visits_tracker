import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:visits_tracker/models/activity.dart';
import '../utils/failure.dart';

class ActivitiesService {
  final String baseUrl;
  final String apiKey;

  ActivitiesService({required this.baseUrl, required this.apiKey});

  Future<Either<Failure, Map<int, String>>> getActivitiesMap() async {
    final url = Uri.parse('$baseUrl/activities');

    final response = await http.get(
      url,
      headers: {'apikey': apiKey, 'Authorization': 'Bearer $apiKey'},
    );

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      final Map<int, String> map = {
        for (var item in jsonList) item['id']: item['description'],
      };
      return right(map);
    } else {
      return left(Failure('Failed to load activities'));
    }
  }

  Future<Either<Failure, List<Activity>>> fetchActivities() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/activities'),
        headers: {'apikey': apiKey, 'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final activities = data.map((a) => Activity.fromJson(a)).toList();
        return right(activities.cast<Activity>());
      } else {
        return left(Failure('Failed to fetch activities'));
      }
    } catch (e) {
      return left(Failure('Error: $e'));
    }
  }

}
