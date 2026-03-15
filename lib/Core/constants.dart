import 'package:flutter/material.dart';

class AppConstants {
  static const List<Map<String, dynamic>> categories = [
    {"name": "Food", "icon": Icons.restaurant_rounded, "color": Colors.orange},
    {
      "name": "Shopping",
      "icon": Icons.shopping_bag_rounded,
      "color": Colors.pink,
    },
    {
      "name": "Transport",
      "icon": Icons.directions_bus_rounded,
      "color": Colors.blue,
    },
    {
      "name": "Bills",
      "icon": Icons.receipt_long_rounded,
      "color": Colors.purple,
    },
    {
      "name": "Health",
      "icon": Icons.medical_services_rounded,
      "color": Colors.red,
    },
    {
      "name": "Travel",
      "icon": Icons.flight_takeoff_rounded,
      "color": Colors.teal,
    },
    {"name": "Education", "icon": Icons.school_rounded, "color": Colors.indigo},
    {"name": "Others", "icon": Icons.more_horiz_rounded, "color": Colors.grey},
  ];

  static Map<String, dynamic> getCategory(String name) {
    return categories.firstWhere(
      (cat) => cat["name"] == name,
      orElse: () => categories.last,
    );
  }
}
