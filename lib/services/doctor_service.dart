import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';

class DoctorService {
  final _db = FirebaseFirestore.instance;

  Stream<List<DoctorModel>> getDoctors() {
    return _db
        .collection('doctors')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DoctorModel.fromDoc(doc)).toList());
  }
}
