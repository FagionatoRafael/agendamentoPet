import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/appointment_provider.dart';
import '../../../core/routes.dart';
import '../../../widgets/appointment_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  int _previousItemCount = 0;

  // Controle de abas
  late TabController _tabController;
  int _currentTabIndex = 0;

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
      final success = await context.read<AppointmentProvider>().deleteAppointment(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento excluído com sucesso!')),
        );
      }
    }
  }

  // Método para finalizar agendamento
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
              var completed = context.read<AppointmentProvider>().completeAppointment(id);
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

  // Método para reabrir agendamento finalizado
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.pending_actions),
              text: 'Agendados',
            ),
            Tab(
              icon: Icon(Icons.check_circle),
              text: 'Finalizados',
            ),
          ],
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          indicatorWeight: 3,
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
                // Determina qual lista mostrar baseado na aba selecionada
                final isActiveTab = _currentTabIndex == 0;
                final appointments = isActiveTab 
                    ? provider.activeAppointments 
                    : provider.completedAppointments;

                final currentCount = appointments.length;

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
                          isActiveTab 
                              ? Icons.pending_actions 
                              : Icons.check_circle,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isActiveTab 
                              ? 'Nenhum agendamento pendente' 
                              : 'Nenhum agendamento finalizado',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isActiveTab 
                              ? 'Clique no botão + para criar um novo' 
                              : 'Finalize um agendamento para aparecer aqui',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (isActiveTab) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _handleRefresh,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Recarregar'),
                          ),
                        ],
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