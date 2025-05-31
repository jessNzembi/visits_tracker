import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:visits_tracker/models/customer.dart';
import '../utils/failure.dart';

class CustomersService {
  final String baseUrl;
  final String apiKey;

  CustomersService({required this.baseUrl, required this.apiKey});


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

  Future<Either<Failure, Map<int, String>>> getCustomerMap() async {
    final result = await fetchCustomers();

    return result.map((customers) => {for (var c in customers) c.id: c.name});
  }
}
