import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _appointments => _firestore.collection('appointments');

  Stream<List<Appointment>> getAppointments() {
    return _appointments
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Appointment.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<List<Appointment>> searchAppointments(String query) {
    return _appointments
        .orderBy('tutorName')
        .startAt([query]).endAt(['$query\uf8ff'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Appointment.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addAppointment(Appointment appointment) async {
    await _appointments.add(appointment.toJson());
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await _appointments.doc(appointment.id).update(appointment.toJson());
  }

  Future<void> deleteAppointment(String id) async {
    await _appointments.doc(id).delete();
  }
}