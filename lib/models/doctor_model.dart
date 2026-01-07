import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String id;
  final String fullName;
  final String specialty;
  final String hospital;
  final String photoUrl;
  final double rating;
  final int patients;
  final int experienceYears;

  DoctorModel({
    required this.id,
    required this.fullName,
    required this.specialty,
    required this.hospital,
    required this.photoUrl,
    required this.rating,
    required this.patients,
    required this.experienceYears,
  });

  factory DoctorModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DoctorModel(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      specialty: data['specialty'] ?? '',
      hospital: data['hospital'] ?? '',
      photoUrl: data['photoUrls'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      patients: data['patients'] ?? 0,
      experienceYears: data['experienceYears'] ?? 0,
    );
  }
}
