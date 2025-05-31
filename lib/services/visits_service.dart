import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:visits_tracker/databases/database_helper.dart';
import '../models/visit.dart';
import '../utils/failure.dart';

class VisitsService {
  final String baseUrl;
  final String apiKey;
  final DatabaseHelper _dbHelper =
      DatabaseHelper();

  VisitsService({required this.baseUrl, required this.apiKey});

  Future<Either<Failure, List<Visit>>> getVisits({
    Map<int, String>? activityMap,
    Map<int, String>? customerMap,
  }) async {
    try {
      //Try to load from local database first
      final localVisits = await _dbHelper.getVisits();
      if (localVisits.isNotEmpty) {
        // Populate UI-only fields from provided maps if available
        final hydratedVisits =
            localVisits.map((visit) {
              if (activityMap != null) {
                visit.activityDescriptions =
                    visit.activitiesDone
                        .map((id) => activityMap[id] ?? 'Unknown Activity')
                        .toList();
              }
              if (customerMap != null) {
                visit.customerName =
                    customerMap[visit.customerId] ?? 'Unknown Customer';
              }
              return visit;
            }).toList();
        return Right(hydratedVisits);
      }

      //If no local data, fetch from API
      final url = Uri.parse('$baseUrl/visits');
      final response = await http.get(
        url,
        headers: {'apikey': apiKey, 'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final visits = jsonList.map((json) => Visit.fromJson(json)).toList();

        //Store fetched data locally
        await _dbHelper
            .deleteAllVisits();
        for (final visit in visits) {
          final hydratedVisit = visit.copyWith(
            activityDescriptions:
                activityMap != null
                    ? visit.activitiesDone
                        .map((id) => activityMap[id] ?? 'Unknown Activity')
                        .toList()
                    : null,
            customerName:
                customerMap != null
                    ? customerMap[visit.customerId] ?? 'Unknown Customer'
                    : "",
          );
          await _dbHelper.insertVisit(hydratedVisit);
        }

        final hydratedVisits =
            visits.map((visit) {
              if (activityMap != null) {
                visit.activityDescriptions =
                    visit.activitiesDone
                        .map((id) => activityMap[id] ?? 'Unknown Activity')
                        .toList();
              }
              if (customerMap != null) {
                visit.customerName =
                    customerMap[visit.customerId] ?? 'Unknown Customer';
              }
              return visit;
            }).toList();

        return Right(hydratedVisits);
      } else {
        return Left(
          Failure(
            "VisitsService: Failed to load visits from API: ${response.statusCode}",
          ),
        );
      }
    } catch (e) {
      // Fallback to local data if API call fails
      final localVisits = await _dbHelper.getVisits();
      if (localVisits.isNotEmpty) {
        final hydratedVisits =
            localVisits.map((visit) {
              if (activityMap != null) {
                visit.activityDescriptions =
                    visit.activitiesDone
                        .map((id) => activityMap[id] ?? 'Unknown Activity')
                        .toList();
              }
              if (customerMap != null) {
                visit.customerName =
                    customerMap[visit.customerId] ?? 'Unknown Customer';
              }
              return visit;
            }).toList();
        return Right(hydratedVisits);
      }
      return Left(
        Failure(
          "VisitsService: Failed to load visits (no network or local data): ${e.toString()}",
        ),
      );
    }
  }

  /// Adds a new visit via API and updates local database.
  Future<Either<Failure, Unit>> addVisit(Visit visit) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/visits'),
        headers: {
          'apikey': apiKey,
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(visit.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newVisit = Visit.fromJson(
          jsonDecode(response.body),
        ); 
        await _dbHelper.insertVisit(newVisit);
        return right(unit);
      } else {
        return left(
          Failure('VisitsService: Failed to create visit: ${response.body}'),
        );
      }
    } catch (e) {
      return left(Failure('VisitsService: Error creating visit: $e'));
    }
  }

  /// Updates an existing visit via API and updates local database.
  Future<Either<Failure, Visit>> updateVisit(
    Visit visit,
    Map<int, String>? activityMap,
    Map<int, String>? customerMap,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/visits?id=eq.${visit.id}'),
        headers: {
          'apikey': apiKey,
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=representation',
        },
        body: jsonEncode(visit.toJson()),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final updatedVisit = Visit.fromJson(data.first);

        final hydratedUpdatedVisit = updatedVisit.copyWith(
          activityDescriptions:
              activityMap != null
                  ? updatedVisit.activitiesDone
                      .map((id) => activityMap[id] ?? 'Unknown Activity')
                      .toList()
                  : null,
          customerName:
              customerMap != null
                  ? customerMap[updatedVisit.customerId] ?? 'Unknown Customer'
                  : "",
        );

        await _dbHelper.updateVisit(hydratedUpdatedVisit);
        return right(hydratedUpdatedVisit);
      } else {
        return left(
          Failure('VisitsService: Failed to update visit: ${response.body}'),
        );
      }
    } catch (e) {
      return left(Failure('VisitsService: Error updating visit: $e'));
    }
  }

  /// Deletes a visit via API and removes it from local database.
  Future<Either<Failure, Unit>> deleteVisit(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/visits?id=eq.$id'),
        headers: {
          'apikey': apiKey,
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
      );

      if (response.statusCode == 204) {
        await _dbHelper.deleteVisit(id);
        return right(unit);
      } else {
        return left(
          Failure('VisitsService: Failed to delete visit: ${response.body}'),
        );
      }
    } catch (e) {
      return left(Failure('VisitsService: Error deleting visit: $e'));
    }
  }

  
}
