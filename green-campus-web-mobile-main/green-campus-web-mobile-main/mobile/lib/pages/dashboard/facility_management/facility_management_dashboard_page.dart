import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/data/services/auth_service.dart';
import 'package:mobile_app/data/services/token_storage.dart';
import 'package:mobile_app/logic/dashboard/facility_management_controller.dart';
import 'package:mobile_app/widgets/common_app_drawer.dart';
import 'package:mobile_app/widgets/common_app_header.dart';

class FacilityManagementDashboardPage extends StatefulWidget {
  const FacilityManagementDashboardPage({super.key});

  @override
  State<StatefulWidget> createState() =>
      _FacilityManagementDashboardPageState();
}

class _FacilityManagementDashboardPageState
    extends State<FacilityManagementDashboardPage> {
  late final FacilityManagementController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FacilityManagementController();
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.bgPage,
          drawer: CommonAppDrawer(
            userName: _controller.userName ?? 'Usuario',
            lastName: _controller.lastName ?? 'Apellido',
            userEmail: _controller.userEmail ?? '',
            role: _controller.role ?? '',
            profileImageUrl: _controller.profileImageUrl,
            onLogout: () => _handleLogout(context),
          ),
          body: SafeArea(
            child: _controller.isLoading && _controller.stats == null
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _controller.fetchManagementData(),
                    child: CustomScrollView(
                      slivers: [
                        CommonAppHeader(
                          userName: _controller.userName ?? 'Usuario',
                          profileImageUrl: _controller.profileImageUrl,
                          showNotificationsBell: true,
                          onNotificationsTap: () =>
                              Navigator.pushNamed(context, '/notifications'),
                        ),
                        _buildManagementContent(),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildManagementContent() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildHeader('Habitabilidad y Confort', subtitle: 'En tiempo real'),
          const SizedBox(height: 16),
          _buildHabitabilityCards(),
          const SizedBox(height: 32),
          _buildHeader(
            'Plan de Manetenimiento',
            count: '${_controller.tasks.length} tareas',
          ),
          const SizedBox(height: 16),
          _buildTasksList(),
        ]),
      ),
    );
  }

  Widget _buildHabitabilityCards() {
    final s = _controller.stats;
    return Row(
      children: [
        _buildStatCard(
          '${s?.averageTemp ?? "--"}°',
          'Temp. Media',
          Icons.thermostat,
          AppColors.accentGreen,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          '${s?.averageCo2 ?? "--"}',
          'CO2 ppm',
          Icons.air,
          AppColors.statusWarning,
        ),
      ],
    );
  }

  // Tarjeta de tarea con cuenta atrás
  Widget _buildTasksList() {
    return Column(
      children: _controller.tasks
          .map(
            (task) => Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.assignment_late_outlined,
                    color: task.daysRemaining < 3
                        ? AppColors.statusOffline
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Faltan ${task.daysRemaining} días',
                          style: TextStyle(
                            color: task.daysRemaining < 3
                                ? AppColors.statusOffline
                                : AppColors.textMuted,
                            fontFamily: 'JetBrains Mono',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // Helper para títulos de sección
  Widget _buildHeader(String title, {String? subtitle, String? count}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          subtitle ?? count ?? '',
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 9,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String val, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              val,
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lógica de destrucción de sesión
  Future<void> _handleLogout(BuildContext context) async {
    final authService = AuthService();

    try {
      // Se intenta avisar al back (petición "fire and forget" con timeout corto)
      await authService.logout().timeout(const Duration(seconds: 4));
    } catch (e) {
      // Si falla el servidor o no hay red, seguimos igual: la prioridad es borrar lo local
      debugPrint('Error en logout del servidor: $e');
    }

    // Borrado de los datos en el dispositivos
    await TokenStorage.clearSession();

    if (!context.mounted) return;

    // Navegación radical: Se borra todo el historial para que no se pueda vilver atrás
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
