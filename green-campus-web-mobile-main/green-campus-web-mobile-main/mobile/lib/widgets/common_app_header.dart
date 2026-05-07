import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';

class CommonAppHeader extends StatelessWidget {
  final String title;
  final String userName;
  final String? profileImageUrl;

  /// Si es true muestra el icono de campana junto al avatar.
  final bool showNotificationsBell;

  /// Acción al pulsar la campana. Requerido si [showNotificationsBell] es true.
  final VoidCallback? onNotificationsTap;

  /// Número de notificaciones sin leer (muestra badge si > 0).
  /// TODO: BACKEND – Alimentar desde NotificationsController cuando exista.
  final int notificationCount;

  const CommonAppHeader({
    super.key,
    this.title = "Green Campus",
    required this.userName,
    this.profileImageUrl,
    this.showNotificationsBell = false,
    this.onNotificationsTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.inputBorder)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            Row(
              children: [
                Image.asset(
                  'resources/images/logoGreenXL.png',
                  height: 35,
                ),
                const SizedBox(width: 7),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            // Perfil simplificado a la derecha
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: Column(
                children: [
                  // Zona derecha: campana (opcional) + perfil
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showNotificationsBell) ...[
                  _buildBellButton(),
                  const SizedBox(width: 4),
                ],
                _buildProfileAvatar(),
              ],
            ),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBellButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textSecondary,
            size: 24,
          ),
          onPressed: onNotificationsTap,
        ),
        // Badge de conteo (visible solo si hay notificaciones pendientes)
        if (notificationCount > 0)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.statusWarning,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  notificationCount > 9 ? '9+' : '$notificationCount',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.inputBorder,
          backgroundImage:
              profileImageUrl != null && profileImageUrl!.isNotEmpty
              ? NetworkImage(profileImageUrl!)
              : null,
          child: profileImageUrl == null || profileImageUrl!.isEmpty
              ? const Icon(Icons.person_outline_rounded, size: 14)
              : null,
        ),
        Text(
          '${userName.split(' ')[0]} ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
