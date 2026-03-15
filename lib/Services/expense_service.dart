import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/expense_model.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection Reference
  CollectionReference get _expensesCollection => _firestore.collection('expenses');

  /// Save Expense to Firestore
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await _expensesCollection.add(expense.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Get Expenses Stream
  Stream<List<ExpenseModel>> getExpenses(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }
    return _expensesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ExpenseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
