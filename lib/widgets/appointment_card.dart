import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../enums/appointment_status.dart';
import '../models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onEdit,
    required this.onDelete,
  });

  // Método para determinar o status do agendamento
  AppointmentStatus _getStatus() {
    final now = DateTime.now();
    final appointmentTime = appointment.date;
    final difference = appointmentTime.difference(now);

    if (difference.inMinutes > 30) {
      return AppointmentStatus.upcoming; // Verde - Longe do horário
    } else if (difference.inMinutes >= 0) {
      return AppointmentStatus.soon; // Amarelo - Próximo do horário
    } else {
      return AppointmentStatus.late; // Vermelho - Atrasado
    }
  }

  // Método para obter as cores baseado no status
  _StatusColors _getColors(BuildContext context) {
    final status = _getStatus();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status) {
      case AppointmentStatus.upcoming:
        return _StatusColors(
          backgroundColor: isDark ? Colors.green.shade900 : Colors.green.shade50,
          borderColor: isDark ? Colors.green.shade700 : Colors.green.shade200,
          textColor: isDark ? Colors.green.shade200 : Colors.green.shade700,
          iconColor: isDark ? Colors.green.shade300 : Colors.green.shade600,
          statusText: '📅 Agendado',
          statusColor: Colors.green,
        );
      case AppointmentStatus.soon:
        return _StatusColors(
          backgroundColor: isDark ? Colors.orange.shade900 : Colors.orange.shade50,
          borderColor: isDark ? Colors.orange.shade700 : Colors.orange.shade200,
          textColor: isDark ? Colors.orange.shade200 : Colors.orange.shade700,
          iconColor: isDark ? Colors.orange.shade300 : Colors.orange.shade600,
          statusText: '⏰ Em breve!',
          statusColor: Colors.orange,
        );
      case AppointmentStatus.late:
        return _StatusColors(
          backgroundColor: isDark ? Colors.red.shade900 : Colors.red.shade50,
          borderColor: isDark ? Colors.red.shade700 : Colors.red.shade200,
          textColor: isDark ? Colors.red.shade200 : Colors.red.shade700,
          iconColor: isDark ? Colors.red.shade300 : Colors.red.shade600,
          statusText: '⚠️ Atrasado!',
          statusColor: Colors.red,
        );
    }
  }

  String _getTimeRemaining() {
    final now = DateTime.now();
    final appointmentTime = appointment.date;
    final difference = appointmentTime.difference(now);

    if (difference.inMinutes < 0) {
      final lateMinutes = difference.inMinutes.abs();
      if (lateMinutes < 60) {
        return 'Atrasado há $lateMinutes min';
      } else {
        final hours = lateMinutes ~/ 60;
        final minutes = lateMinutes % 60;
        return 'Atrasado há $hours:${minutes.toString().padLeft(2, '0')}h';
      }
    } else if (difference.inMinutes < 60) {
      return 'Em ${difference.inMinutes} min';
    } else {
      final hours = difference.inMinutes ~/ 60;
      final minutes = difference.inMinutes % 60;
      if (hours < 24) {
        return 'Em $hours:${minutes.toString().padLeft(2, '0')}h';
      } else {
        return 'Em ${hours ~/ 24} dias';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(context);
    final status = _getStatus();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: status == AppointmentStatus.late ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colors.borderColor,
          width: status == AppointmentStatus.late ? 2 : 1,
        ),
      ),
      color: colors.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha do cabeçalho com status e tempo restante
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(
                    appointment.tutorName[0].toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.tutorName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Pet: ${appointment.petName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),                
                // Preço
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    'R\$ ${appointment.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Barra de tempo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.statusColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    status == AppointmentStatus.upcoming
                        ? Icons.timer
                        : status == AppointmentStatus.soon
                            ? Icons.alarm
                            : Icons.warning,
                    size: 20,
                    color: colors.iconColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getTimeRemaining(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: colors.textColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Mostra a hora do agendamento
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: colors.iconColor),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('HH:mm').format(appointment.date),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.textColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Serviços
            Wrap(
              spacing: 8,
              children: [
                if (appointment.bath)
                  Chip(
                    label: const Text('Banho'),
                    backgroundColor: Colors.blue.shade50,
                    labelStyle: TextStyle(color: Colors.blue.shade700),
                    avatar: Icon(Icons.shower, size: 16, color: Colors.blue.shade700),
                  ),
                if (appointment.grooming)
                  Chip(
                    label: Text(Appointment.getGroomingTypeName(appointment.groomingType)),
                    backgroundColor: Colors.green.shade50,
                    labelStyle: TextStyle(color: Colors.green.shade700),
                    avatar: Icon(Icons.cut, size: 16, color: Colors.green.shade700),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Data e hora
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(appointment.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  DateFormat('HH:mm').format(appointment.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (appointment.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                appointment.notes,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
// Classe para armazenar as cores do status
class _StatusColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final String statusText;
  final Color statusColor;

  _StatusColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.statusText,
    required this.statusColor,
  });
}