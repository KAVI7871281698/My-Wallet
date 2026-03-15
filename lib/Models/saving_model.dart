import 'package:cloud_firestore/cloud_firestore.dart';

class SavingModel {
  final String? id;
  final double amount;
  final DateTime date;
  final String userId;

  SavingModel({
    this.id,
    required this.amount,
    required this.date,
    required this.userId,
  });

  Map<String, dynamic> toMap({bool forFirestore = true}) {
    return {
      'amount': amount,
      'date': forFirestore ? Timestamp.fromDate(date) : date.toIso8601String(),
      'userId': userId,
    };
  }

  factory SavingModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate;
    if (map['date'] is Timestamp) {
      parsedDate = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      parsedDate = DateTime.parse(map['date']);
    } else {
      parsedDate = DateTime.now();
    }

    return SavingModel(
      id: id,
      amount: (map['amount'] as num).toDouble(),
      date: parsedDate,
      userId: map['userId'] ?? '',
    );
  }
}
