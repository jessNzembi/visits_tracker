import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:visits_tracker/databases/database_helper.dart';
import 'package:visits_tracker/models/customer.dart';
import '../utils/failure.dart';

class CustomersService {
  final String baseUrl;
  final String apiKey;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  CustomersService({required this.baseUrl, required this.apiKey});


  Future<Either<Failure, List<Customer>>> fetchCustomers() async {
    try {
      // Try to load from local database first
      final localCustomers = await _dbHelper.getCustomers();
      if (localCustomers.isNotEmpty) {
        return Right(localCustomers);
      }

      //If no local data, fetch from API
      final response = await http.get(
        Uri.parse('$baseUrl/customers'),
        headers: {'apikey': apiKey, 'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final customers =
            jsonList.map((json) => Customer.fromJson(json)).toList();

        //Store fetched data locally
        await _dbHelper
            .deleteAllCustomers();
        for (final customer in customers) {
          await _dbHelper.insertCustomer(customer);
        }
        return Right(customers);
      } else {
        return Left(
          Failure(
            "VisitsService: Failed to fetch customers from API: ${response.statusCode}",
          ),
        );
      }
    } catch (e) {
      // Fallback to local data if API call fails
      final localCustomers = await _dbHelper.getCustomers();
      if (localCustomers.isNotEmpty) {
        return Right(localCustomers);
      }
      return Left(
        Failure(
          "VisitsService: Failed to fetch customers (no network or local data): ${e.toString()}",
        ),
      );
    }
  }

  Future<Either<Failure, Map<int, String>>> getCustomerMap() async {
    final result = await fetchCustomers();

    return result.map((customers) => {for (var c in customers) c.id: c.name});
  }
}
