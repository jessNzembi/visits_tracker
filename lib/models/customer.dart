class Customer {
  final int id;
  final String name;
  final DateTime createdAt;

  Customer({required this.id, required this.name, required this.createdAt});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
