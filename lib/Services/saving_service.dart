import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/saving_model.dart';

class SavingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection Reference
  CollectionReference get _savingsCollection => _firestore.collection('savings');

  /// Save Saving to Firestore
  Future<void> addSaving(SavingModel saving) async {
    try {
      await _savingsCollection.add(saving.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Get Savings Stream
  Stream<List<SavingModel>> getSavings(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }
    return _savingsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.map((doc) {
        return SavingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      
      // Sort on client-side to fix "Index Required" error instantly
      docs.sort((a, b) => b.date.compareTo(a.date));
      return docs;
    });
  }

  /// Get Total Savings
  Stream<double> getTotalSavings(String userId) {
    return getSavings(userId).map((savings) {
      return savings.fold(0.0, (previousValue, element) => previousValue + element.amount);
    });
  }
}
