import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:visits_tracker/databases/database_helper.dart';
import 'package:visits_tracker/models/activity.dart';
import '../utils/failure.dart';

class ActivitiesService {
  final String baseUrl;
  final String apiKey;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  ActivitiesService({required this.baseUrl, required this.apiKey});
  
  Future<Either<Failure, Map<int, String>>> getActivitiesMap() async {
    final result = await fetchActivities();
    return result.fold(
      (failure) => Left(failure),
      (activities) {
        final Map<int, String> map = {
          for (var item in activities) item.id: item.description,
        };
        return Right(map);
      },
    );
  }

  /// Fetches a list of activities, prioritizing local storage.
  Future<Either<Failure, List<Activity>>> fetchActivities() async {
    try {
      //Try to load from local database first
      final localActivities = await _dbHelper.getActivities();
      if (localActivities.isNotEmpty) {
        return Right(localActivities);
      }

      //If no local data, fetch from API
      final response = await http.get(
        Uri.parse('$baseUrl/activities'),
        headers: {'apikey': apiKey, 'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final List jsonList = jsonDecode(response.body);
        final activities = jsonList.map((json) => Activity.fromJson(json)).toList();

        //Store fetched data locally
        await _dbHelper.deleteAllActivities();
        for (final activity in activities) {
          await _dbHelper.insertActivity(activity);
        }
        return Right(activities);
      } else {
        return Left(Failure("Failed to load activities from API: ${response.statusCode}"));
      }
    } catch (e) {
      // Return local data if API call fails
      final localActivities = await _dbHelper.getActivities();
      if (localActivities.isNotEmpty) {
        return Right(localActivities);
      }
      return Left(Failure("Failed to load activities (no network or local data): ${e.toString()}"));
    }
  }
}

