import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _patients =>
      _db.collection('Patients');

  // CREATE
  Future<String> createPatient({
    required String name,
    required String dateOfBirth,
    required String gender,
    required String idNumber,
    required String address,
    required String phoneNumber,
    required String medicalAidNumber,
  }) async {
    try {
      DocumentReference doc = await _patients.add({
        'name': name.trim(),
        'dateOfBirth': dateOfBirth.trim(),
        'gender': gender,
        'idNumber': idNumber.trim(),
        'address': address.trim(),
        'phoneNumber': phoneNumber.trim(),
        'medicalAidNumber': medicalAidNumber.trim(),
        'createdByUserId': _auth.currentUser?.uid ?? 'unknown',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      throw Exception('Failed to create patient: $e');
    }
  }

  // READ ALL (Real-time stream)
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllPatients() {
    return _patients.orderBy('createdAt', descending: true).snapshots();
  }

  // UPDATE
  Future<void> updatePatient({
    required String patientId,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      updatedData['updatedAt'] = FieldValue.serverTimestamp();
      updatedData['updatedByUserId'] = _auth.currentUser?.uid ?? 'unknown';
      await _patients.doc(patientId).update(updatedData);
    } catch (e) {
      throw Exception('Failed to update patient: $e');
    }
  }

  // DELETE
  Future<void> deletePatient(String patientId) async {
    try {
      await _patients.doc(patientId).delete();
    } catch (e) {
      throw Exception('Failed to delete patient: $e');
    }
  }
}