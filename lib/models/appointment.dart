import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String tutorName;
  final String petName;
  final bool bath;
  final bool grooming;
  final DateTime date;
  final String notes;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.tutorName,
    required this.petName,
    required this.bath,
    required this.grooming,
    required this.date,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'tutorName': tutorName,
      'petName': petName,
      'bath': bath,
      'grooming': grooming,
      'date': date,
      'notes': notes,
      'createdAt': createdAt,
    };
  }

  factory Appointment.fromJson(String id, Map<String, dynamic> json) {
    return Appointment(
      id: id,
      tutorName: json['tutorName'] ?? '',
      petName: json['petName'] ?? '',
      bath: json['bath'] ?? false,
      grooming: json['grooming'] ?? false,
      date: (json['date'] as Timestamp).toDate(),
      notes: json['notes'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Appointment copyWith({
    String? id,
    String? tutorName,
    String? petName,
    bool? bath,
    bool? grooming,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      tutorName: tutorName ?? this.tutorName,
      petName: petName ?? this.petName,
      bath: bath ?? this.bath,
      grooming: grooming ?? this.grooming,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}