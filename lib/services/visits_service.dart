import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:visits_tracker/models/customer.dart';
import '../models/visit.dart';
import '../utils/failure.dart';

class VisitsService {
  final String baseUrl;
  final String apiKey;

  VisitsService({required this.baseUrl, required this.apiKey});

  Future<Either<Failure, List<Visit>>> getVisits({
    Map<int, String>? activityMap,
    Map<int, String>? customerMap,
  }) async {
    final url = Uri.parse('$baseUrl/visits');
    final response = await http.get(
      url,
      headers: {'apikey': apiKey, 'Authorization': 'Bearer $apiKey'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final visits =
          data.map((v) {
            final visit = Visit.fromJson(v);
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
      return right(visits);
    } else {
      return left(Failure('Failed to load visits'));
    }
  }

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
        return right(unit);
      } else {
        return left(Failure('Failed to create visit: ${response.body}'));
      }
    } catch (e) {
      return left(Failure('Error creating visit: $e'));
    }
  }

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

        final visit = Visit.fromJson(data.first);
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

        return right(visit);
      } else {
        return left(Failure('Failed to update visit: ${response.body}'));
      }
    } catch (e) {
      return left(Failure('Error updating visit: $e'));
    }
  }

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
        return right(unit);
      } else {
        return left(Failure('Failed to delete visit: ${response.body}'));
      }
    } catch (e) {
      return left(Failure('Error deleting visit: $e'));
    }
  }

  Future<Either<Failure, List<Customer>>> fetchCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customers'),
        headers: {'apikey': apiKey, 'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final customers = data.map((c) => Customer.fromJson(c)).toList();
        return right(customers.cast<Customer>());
      } else {
        return left(Failure('Failed to fetch customers'));
      }
    } catch (e) {
      return left(Failure('Error: $e'));
    }
  }
}
