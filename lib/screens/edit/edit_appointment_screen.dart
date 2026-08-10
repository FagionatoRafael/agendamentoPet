import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/appointment.dart';
import '../../../providers/appointment_provider.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/loading.dart';
import '../../../utils/validators.dart';

class EditAppointmentScreen extends StatefulWidget {
  final String appointmentId;
  final Appointment appointment;

  const EditAppointmentScreen({
    super.key,
    required this.appointmentId,
    required this.appointment,
  });

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tutorController = TextEditingController();
  final _petController = TextEditingController();
  final _notesController = TextEditingController();
  bool _bath = false;
  bool _grooming = false;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tutorController.text = widget.appointment.tutorName;
    _petController.text = widget.appointment.petName;
    _notesController.text = widget.appointment.notes;
    _bath = widget.appointment.bath;
    _grooming = widget.appointment.grooming;
    _selectedDate = widget.appointment.date;
    _selectedTime = TimeOfDay.fromDateTime(widget.appointment.date);
  }

  @override
  void dispose() {
    _tutorController.dispose();
    _petController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_bath && !_grooming) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione pelo menos um serviço (Banho ou Tosa)'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final updatedAppointment = widget.appointment.copyWith(
        tutorName: _tutorController.text.trim(),
        petName: _petController.text.trim(),
        bath: _bath,
        grooming: _grooming,
        date: dateTime,
        notes: _notesController.text.trim(),
      );

      final success = await context.read<AppointmentProvider>().updateAppointment(updatedAppointment);

      setState(() => _isSubmitting = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento atualizado com sucesso!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Agendamento'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _tutorController,
                    label: 'Nome do Tutor',
                    icon: Icons.person,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _petController,
                    label: 'Nome do Pet',
                    icon: Icons.pets,
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Serviços',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          value: _bath,
                          onChanged: (value) {
                            setState(() => _bath = value ?? false);
                          },
                          title: const Text('Banho'),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          value: _grooming,
                          onChanged: (value) {
                            setState(() => _grooming = value ?? false);
                          },
                          title: const Text('Tosa'),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _selectDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Data',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: _selectTime,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Hora',
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            child: Text(_selectedTime.format(context)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _notesController,
                    label: 'Observações',
                    icon: Icons.note,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleUpdate,
                      child: const Text('Atualizar Agendamento'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isSubmitting) const Loading(),
        ],
      ),
    );
  }
}