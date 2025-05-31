import 'package:flutter/material.dart';
import '../../models/visit.dart';

class VisitCard extends StatelessWidget {
  final Visit visit;
  final VoidCallback? onTap;

  const VisitCard({super.key, required this.visit, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        onTap: onTap,
        title: Text(visit.customerName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: ${visit.visitDate.toLocal()}"),
            Text("Status: ${visit.status}"),
            Text("Location: ${visit.location}"),
          ],
        ),
        trailing: Icon(
          visit.status == "Completed"
              ? Icons.check_circle
              : visit.status == "Pending"
              ? Icons.schedule
              : Icons.cancel,
          color:
              visit.status == "Completed"
                  ? Colors.green
                  : visit.status == "Pending"
                  ? Colors.orange
                  : Colors.red,
        ),
      ),
    );
  }
}
