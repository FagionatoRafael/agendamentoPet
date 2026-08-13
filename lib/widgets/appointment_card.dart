import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../enums/appointment_status.dart';
import '../models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onComplete;
  final VoidCallback? onReopen;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onEdit,
    required this.onDelete,
    this.onComplete,
    this.onReopen,
  });

  AppointmentStatus _getStatus() {
    if (appointment.isCompleted) {
      return AppointmentStatus.completed;
    }

    final now = DateTime.now();
    final appointmentTime = appointment.date;
    final difference = appointmentTime.difference(now);

    if (difference.inMinutes > 30) {
      return AppointmentStatus.upcoming;
    } else if (difference.inMinutes >= 0) {
      return AppointmentStatus.soon;
    } else {
      return AppointmentStatus.late;
    }
  }

  _StatusColors _getColors(BuildContext context) {
    final status = _getStatus();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (status == AppointmentStatus.completed) {
      return _StatusColors(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderColor: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
        textColor: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
        iconColor: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
        statusText: '✅ Finalizado',
        statusColor: Colors.grey,
      );
    }

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
      default:
        return _StatusColors(
          backgroundColor: Colors.grey.shade100,
          borderColor: Colors.grey.shade300,
          textColor: Colors.grey.shade600,
          iconColor: Colors.grey.shade500,
          statusText: '',
          statusColor: Colors.grey,
        );
    }
  }

  String _getTimeRemaining() {
    if (appointment.isCompleted) {
      return '✅ Serviço concluído';
    }

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
    final isCompleted = appointment.isCompleted;

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
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isCompleted 
                      ? Colors.grey 
                      : Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(
                    appointment.tutorName[0].toUpperCase(),
                    style: TextStyle(
                      color: isCompleted ? Colors.white : Theme.of(context).primaryColor,
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? Colors.grey : null,
                        ),
                      ),
                      Text(
                        'Pet: ${appointment.petName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isCompleted ? Colors.grey : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.grey.shade200 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCompleted ? Colors.grey.shade300 : Colors.green.shade200,
                    ),
                  ),
                  child: Text(
                    'R\$ ${appointment.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.grey : Colors.green.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton(
                  itemBuilder: (context) {
                    final items = <PopupMenuEntry>[];
                    
                    // Opção Editar (apenas para não finalizados)
                    if (!isCompleted) {
                      items.add(
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
                      );
                    }

                    // Opção Finalizar
                    if (!isCompleted && onComplete != null) {
                      items.add(
                        const PopupMenuItem(
                          value: 'complete',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Finalizar', style: TextStyle(color: Colors.green)),
                            ],
                          ),
                        ),
                      );
                    }

                    // Opção Reabrir
                    if (isCompleted && onReopen != null) {
                      items.add(
                        const PopupMenuItem(
                          value: 'reopen',
                          child: Row(
                            children: [
                              Icon(Icons.refresh, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Reabrir', style: TextStyle(color: Colors.orange)),
                            ],
                          ),
                        ),
                      );
                    }

                    // Opção Excluir
                    items.add(
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
                    );

                    return items;
                  },
                  onSelected: (value) {
                    if (value == 'edit' && !isCompleted) {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    } else if (value == 'complete' && onComplete != null) {
                      onComplete!();
                    } else if (value == 'reopen' && onReopen != null) {
                      onReopen!();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isCompleted 
                    ? Colors.grey.shade200 
                    : colors.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCompleted 
                      ? Colors.grey.shade300 
                      : colors.statusColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCompleted 
                        ? Icons.check_circle
                        : status == AppointmentStatus.upcoming
                            ? Icons.timer
                            : status == AppointmentStatus.soon
                                ? Icons.alarm
                                : Icons.warning,
                    size: 20,
                    color: isCompleted ? Colors.grey : colors.iconColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isCompleted ? '✅ Concluído' : _getTimeRemaining(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isCompleted ? Colors.grey : colors.textColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: isCompleted ? Colors.grey : colors.iconColor),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('HH:mm').format(appointment.date),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.grey : colors.textColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              children: [
                if (appointment.bath)
                  Chip(
                    label: Text('Banho', style: TextStyle(
                      color: isCompleted ? Colors.grey : Colors.blue.shade700,
                    )),
                    backgroundColor: isCompleted 
                        ? Colors.grey.shade200 
                        : Colors.blue.shade50,
                    avatar: Icon(Icons.shower, size: 16, color: isCompleted ? Colors.grey : Colors.blue.shade700),
                  ),
                if (appointment.grooming)
                  Chip(
                    label: Text(
                      Appointment.getGroomingTypeName(appointment.groomingType),
                      style: TextStyle(
                        color: isCompleted ? Colors.grey : Colors.green.shade700,
                      ),
                    ),
                    backgroundColor: isCompleted 
                        ? Colors.grey.shade200 
                        : Colors.green.shade50,
                    avatar: Icon(Icons.cut, size: 16, color: isCompleted ? Colors.grey : Colors.green.shade700),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: isCompleted ? Colors.grey : Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(appointment.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isCompleted ? Colors.grey : null,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: isCompleted ? Colors.grey : Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  DateFormat('HH:mm').format(appointment.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isCompleted ? Colors.grey : null,
                  ),
                ),
              ],
            ),
            if (appointment.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                appointment.notes,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isCompleted ? Colors.grey : null,
                ),
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