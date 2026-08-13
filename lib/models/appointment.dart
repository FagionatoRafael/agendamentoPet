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
  final String groomingType;
  final double totalPrice;
  final bool isCompleted;

  Appointment({
    required this.id,
    required this.tutorName,
    required this.petName,
    required this.bath,
    required this.grooming,
    required this.date,
    this.notes = '',
    required this.createdAt,
    this.groomingType = '',
    this.totalPrice = 0.0,
     this.isCompleted = false,
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
      'groomingType': groomingType,
      'totalPrice': totalPrice,
      'isCompleted': isCompleted,
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
      groomingType: json['groomingType'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      isCompleted: json['isCompleted'] ?? false,
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
    String? groomingType,
    double? totalPrice,
    bool? isCompleted,
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
      groomingType: groomingType ?? this.groomingType,
      totalPrice: totalPrice ?? this.totalPrice,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Método para calcular o preço
  static double calculatePrice(bool bath, bool grooming, String groomingType) {
    if (!bath && !grooming) return 0.0;

    if (bath && !grooming) return 60.0;

    if (!bath && grooming) return 60.0;

    if (bath && grooming) {
      switch (groomingType) {
        case 'higienica':
          return 60.0; // Banho + Tosa Higiênica
        case 'maquina':
          return 80.0; // Banho + Tosa na Máquina
        case 'tesoura':
          return 120.0; // Banho + Tosa na Tesoura
        default:
          return 80.0; // Valor padrão (maquina)
      }
    }

    return 0.0;
  }

  // Método para obter o nome do tipo de tosa
  static String getGroomingTypeName(String type) {
    switch (type) {
      case 'higienica':
        return 'Tosa Higiênica';
      case 'maquina':
        return 'Tosa na Máquina';
      case 'tesoura':
        return 'Tosa na Tesoura';
      default:
        return '';
    }
  }
}