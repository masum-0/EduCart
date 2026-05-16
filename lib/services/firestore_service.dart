import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser({
    required String uid,
    required String name,
    required String email,
    required String dob,
  }) async {
    await _db.collection("users").doc(uid).set({
      "uid": uid,
      "name": name,
      "email": email,
      "dob": dob,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}