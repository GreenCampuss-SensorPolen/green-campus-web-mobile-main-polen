import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/core/constants/user_roles.dart';

class CommonAppDrawer extends StatelessWidget {
  final String userName;
  final String lastName;
  final String userEmail;
  final String? profileImageUrl;
  final String role;
  final VoidCallback onLogout;
  final List<Widget>?
  customItems; // Esto es por si algún rol requiere de algo extra

  const CommonAppDrawer({
    super.key,
    required this.userName,
    required this.lastName,
    required this.userEmail,
    required this.role,
    this.profileImageUrl,
    required this.onLogout,
    this.customItems,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.bgPage,
      child: Column(
        children: [
          // ----- Header del menú -----
          _buildHeader(context),

          const Divider(height: 1, color: AppColors.inputBorder),

          // ----- Opciones de navegación según tipo de usuario -----
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                ..._buildMenuItems(context),
              ],
            ),
          ),

          // ----- Logout -----
          const Spacer(),
          const Divider(height: 1, color: AppColors.inputBorder),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text(
              "Cerrar sesión",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: onLogout,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: const BoxDecoration(color: AppColors.accentGreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.energy_savings_leaf_outlined,
                color: Colors.white,
                size: 26,
              ),
              const SizedBox(width: 10),
              const Text(
                'Green Campus',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // Cierra el drawer
              Navigator.of(context).pushNamed('/profile');
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.chartLineProjected,
                  backgroundImage:
                      profileImageUrl != null && profileImageUrl!.isNotEmpty
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null || profileImageUrl!.isEmpty
                      ? const Icon(
                          Icons.person_outline_rounded,
                          size: 22,
                          color: AppColors.textMuted,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName.isEmpty && lastName.isEmpty
                            ? 'Usuario'
                            : '$userName $lastName',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          _buildRoleChip(),
        ],
      ),
    );
  }

  Widget _buildRoleChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _formatRoleLabel(role),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatRoleLabel(String role) {
    switch (role) {
      case UserRoles.directivo:
        return 'DIRECTIVO';
      case UserRoles.serviciosGenerales:
        return 'SERVICIOS GENERALES';
      case UserRoles.tecnico:
        return 'TECNICO';
      default:
        return role;
    }
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    return [
      // Menú para el rol directivo
      if (role == UserRoles.directivo)
        _buildNavTile(
          context,
          icon: Icons.bar_chart_rounded,
          label: 'Dashboard Directivo',
          route: '/dashboard-directivo',
        ),

      // Menú para el rol tecnico
      if (role == UserRoles.tecnico) _buildTechnicalExpansionTile(context),

      // Menú para el rol de servicios generales
      if (role == UserRoles.serviciosGenerales)
        _buildNavTile(
          context,
          icon: Icons.settings_suggest_rounded,
          label: 'Dashboard Servicios Generales',
          route: '/dashboard-servicios',
        ),

      // Notificaciones: visible para TECNICO y SERVICIOS_GENERALES.
      // useReplace: false → pushNamed en lugar de pushReplacementNamed, para que
      // el botón "atrás" vuelva al dashboard y no deje la pila vacía.
      // TODO: NUEVO ROL – Añadir aquí si otro rol también debe ver notificaciones.
      if (role == UserRoles.tecnico || role == UserRoles.serviciosGenerales)
        _buildNavTile(
          context,
          icon: Icons.notifications_none_rounded,
          label: 'Notificaciones',
          route: '/notifications',
          useReplace: false,
        ),
    ];
  }

  Widget _buildTechnicalExpansionTile(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: const Icon(
          Icons.monitor_heart_rounded,
          color: AppColors.textSecondary,
        ),
        title: const Text(
          'Dashboard Técnico',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
        children: [
          // Vista general
          _buildSubNavTile(
            context,
            icon: Icons.dashboard_rounded,
            label: 'Vista General',
            route: '/dashboard-tecnico',
          ),
          // Vista de un sensor específico
          _buildSubNavTile(
            context,
            icon: Icons.sensors_rounded,
            label: 'Tipos de Sensor',
            route: null,
          ),
          // Vista de un hardware específico (buscar por ID)
          _buildSubNavTile(
            context,
            icon: Icons.devices_rounded,
            label: 'ID de Dispositivo',
            route: '/device-id',
            useReplace: false, // pushNamed: permite volver atrás con el botón
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    // false → pushNamed (sub-pantalla, el botón atrás vuelve al dashboard)
    // true  → pushReplacementNamed (cambio de dashboard, no apila)
    bool useReplace = true,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      ),
      onTap: () {
        Navigator.of(context).pop(); // Cierra el drawer antes de navegar
        if (useReplace) {
          Navigator.of(context).pushReplacementNamed(route);
        } else {
          Navigator.of(context).pushNamed(route);
        }
      },
    );
  }

  Widget _buildSubNavTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String? route,
    // false → pushNamed (sub-pantalla, el botón atrás vuelve al origen)
    // true  → pushReplacementNamed (cambio de sección, no apila)
    bool useReplace = true,
  }) {
    final bool isReady = route != null;

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 56, right: 16),
      leading: Icon(
        icon,
        color: isReady
            ? AppColors.textSecondary
            : AppColors.textSecondary.withAlpha(120),
        size: 18,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: isReady ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
      trailing: !isReady
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.statusWarningBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Pronto',
                style: TextStyle(fontSize: 9, color: AppColors.statusWarning),
              ),
            )
          : null,
      onTap: isReady
          ? () {
              Navigator.of(context).pop();
              if (useReplace) {
                Navigator.of(context).pushReplacementNamed(route);
              } else {
                Navigator.of(context).pushNamed(route);
              }
            }
          : null,
    );
  }
}
