import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/firestore_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

   List<Appointment> get activeAppointments => 
      _appointments.where((a) => !a.isCompleted).toList();
  
  List<Appointment> get completedAppointments => 
      _appointments.where((a) => a.isCompleted).toList();

  void listenToAppointments() {
    _isLoading = true;
    notifyListeners();

    _service.getAppointments().listen(
          (appointments) {
        _appointments = appointments;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void searchAppointments(String query) {
    if (query.isEmpty) {
      listenToAppointments();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _service.searchAppointments(query).listen(
          (appointments) {
        _appointments = appointments;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> addAppointment(Appointment appointment) async {
    try {
      await _service.addAppointment(appointment);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAppointment(Appointment appointment) async {
    try {
      await _service.updateAppointment(appointment);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAppointment(String id) async {
    try {
      await _service.deleteAppointment(id);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  Future<void> refreshAppointments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.getAppointments().first.then((appointments) {
        _appointments = appointments;
        _isLoading = false;
        _error = null;
        notifyListeners();
      }).catchError((error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
        throw Exception('Falha ao atualizar: $error');
      });
    } catch (e) {
      // Re-lança para tratamento na UI
      rethrow;
    }
  }

  Future<bool> completeAppointment(String id) async {
    final appointment = _appointments.firstWhere((a) => a.id == id);
    final updatedAppointment = appointment.copyWith(
        tutorName: appointment.tutorName,
        petName: appointment.petName,
        bath: appointment.bath,
        grooming: appointment.grooming,
        groomingType: appointment.groomingType,
        totalPrice: appointment.totalPrice,
        date: appointment.date,
        notes: appointment.notes,
        isCompleted: true
      );
    try {
      await _service.updateAppointment(updatedAppointment);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> reopenAppointment(String id) async {
    final appointment = _appointments.firstWhere((a) => a.id == id);
    final updatedAppointment = appointment.copyWith(
        tutorName: appointment.tutorName,
        petName: appointment.petName,
        bath: appointment.bath,
        grooming: appointment.grooming,
        groomingType: appointment.groomingType,
        totalPrice: appointment.totalPrice,
        date: appointment.date,
        notes: appointment.notes,
        isCompleted: false
      );
    try {
      await _service.updateAppointment(updatedAppointment);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}