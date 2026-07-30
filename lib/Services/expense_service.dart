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
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.map((doc) {
        return ExpenseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      
      // Sort on client-side to fix "Index Required" error instantly
      docs.sort((a, b) => b.date.compareTo(a.date));
      return docs;
    });
  }
}
