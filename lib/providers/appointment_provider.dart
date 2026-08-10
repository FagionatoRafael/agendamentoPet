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
}