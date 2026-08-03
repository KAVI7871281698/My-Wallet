import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String? id;
  final double amount;
  final String category;
  final DateTime date;
  final String userId;

  ExpenseModel({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.userId,
  });

  Map<String, dynamic> toMap({bool forFirestore = true}) {
    return {
      'amount': amount,
      'category': category,
      'date': forFirestore ? Timestamp.fromDate(date) : date.toIso8601String(),
      'userId': userId,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate;
    if (map['date'] is Timestamp) {
      parsedDate = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      parsedDate = DateTime.parse(map['date']);
    } else {
      parsedDate = DateTime.now();
    }

    return ExpenseModel(
      id: id,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] ?? '',
      date: parsedDate,
      userId: map['userId'] ?? '',
    );
  }
}
