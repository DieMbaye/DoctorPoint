import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map(
          (doc) => doc.data()!,
        );
  }
}
