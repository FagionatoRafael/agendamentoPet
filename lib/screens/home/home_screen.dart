import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/appointment_provider.dart';
import '../../../core/routes.dart';
import '../../../widgets/appointment_card.dart';
import '../../models/appointment.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  int _previousItemCount = 0;

  late TabController _tabController;
  int _currentTabIndex = 0;

  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _dayFormat = DateFormat('EEEE');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppointmentProvider>();
      provider.listenToAppointments();
      _previousItemCount = provider.activeAppointments.length;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleSearch(String query) {
    context.read<AppointmentProvider>().searchAppointments(query);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
        _handleSearch('');
      }

      await context.read<AppointmentProvider>().refreshAppointments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamentos atualizados!'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _handleDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir este agendamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await context
          .read<AppointmentProvider>()
          .deleteAppointment(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento excluído com sucesso!')),
        );
      }
    }
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  List<Appointment> _filterByDate(List<Appointment> appointments) {
    return appointments.where((appointment) {
      final appointmentDate = DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
      );
      final selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      return appointmentDate == selectedDate;
    }).toList();
  }

  void _handleComplete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Agendamento'),
        content: const Text('Confirma que este serviço foi concluído?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppointmentProvider>().completeAppointment(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Agendamento finalizado com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _handleReopen(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reabrir Agendamento'),
        content: const Text('Deseja reabrir este agendamento finalizado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppointmentProvider>().reopenAppointment(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔄 Agendamento reaberto!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Reabrir'),
          ),
        ],
      ),
    );
  }

  bool _hasAppointmentsOnDate(List<Appointment> appointments) {
    return appointments.any((appointment) {
      final appointmentDate = DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
      );
      final selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      return appointmentDate == selectedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        // 🆕 Define a altura da toolbar
        toolbarHeight: 56,
        // 🆕 Usa PreferredSize para o TabBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.pending_actions), text: 'Agendados'),
              Tab(icon: Icon(Icons.check_circle), text: 'Finalizados'),
            ],
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            indicatorWeight: 3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.vertical_align_top),
            onPressed: _scrollToTop,
            tooltip: 'Ir para o topo',
          ),
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _handleRefresh,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Seletor de data
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 32),
                  onPressed: _previousDay,
                  tooltip: 'Dia anterior',
                ),
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: _goToToday,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _dateFormat.format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Consumer<AppointmentProvider>(
                          builder: (context, provider, child) {
                            final isActiveTab = _currentTabIndex == 0;
                            final appointments = isActiveTab
                                ? provider.activeAppointments
                                : provider.completedAppointments;
                            final hasAppointments = _hasAppointmentsOnDate(
                              appointments,
                            );

                            return hasAppointments
                                ? Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${appointments.where((a) => DateTime(a.date.year, a.date.month, a.date.day) == DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)).length} agendamentos',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 32),
                  onPressed: _nextDay,
                  tooltip: 'Próximo dia',
                ),
              ],
            ),
          ),
          // Campo de busca
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por tutor...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _handleSearch,
            ),
          ),
          Expanded(
            child: Consumer<AppointmentProvider>(
              builder: (context, provider, child) {
                final isActiveTab = _currentTabIndex == 0;
                final allAppointments = isActiveTab
                    ? provider.activeAppointments
                    : provider.completedAppointments;

                final appointments = _filterByDate(allAppointments);

                if (provider.isLoading && !_isRefreshing) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar agendamentos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.listenToAppointments(),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                if (appointments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum agendamento para esta data',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _dateFormat.format(_selectedDate),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        if (_selectedDate != DateTime.now())
                          ElevatedButton.icon(
                            onPressed: _goToToday,
                            icon: const Icon(Icons.today),
                            label: const Text('Ir para hoje'),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Colors.white,
                  strokeWidth: 2,
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppointmentCard(
                          appointment: appointment,
                          onEdit: () {
                            if (!appointment.isCompleted) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.edit,
                                arguments: {
                                  'id': appointment.id,
                                  'appointment': appointment,
                                },
                              );
                            }
                          },
                          onDelete: () => _handleDelete(appointment.id),
                          onComplete: appointment.isCompleted
                              ? null
                              : () => _handleComplete(appointment.id),
                          onReopen: appointment.isCompleted
                              ? () => _handleReopen(appointment.id)
                              : null,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AppRoutes.add);
          if (result == true && mounted) {
            _scrollToTop();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Agendamento'),
      ),
    );
  }
}
