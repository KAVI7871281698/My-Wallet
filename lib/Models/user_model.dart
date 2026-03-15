class UserModel {
  final String? uid;
  final String name;
  final String email;
  final String mobile;
  final DateTime? createdAt;

  UserModel({
    this.uid,
    required this.name,
    required this.email,
    required this.mobile,
    this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'mobile': mobile,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      mobile: map['mobile'] ?? '',
      createdAt: map['createdAt'] != null ? (map['createdAt'] as dynamic).toDate() : null,
    );
  }
}
