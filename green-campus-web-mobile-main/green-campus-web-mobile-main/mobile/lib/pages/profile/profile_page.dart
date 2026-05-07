import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_borders.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/logic/profile/profile_controller.dart';
import 'package:mobile_app/widgets/primary_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.bgPage,
          body: SafeArea(
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAvatarSection(),
                              const SizedBox(height: 24),
                              _buildSectionLabel(
                                'INFORMACIÓN PERSONAL',
                                Icons.person_outline,
                              ),
                              const SizedBox(height: 12),
                              _buildPersonalInfoCard(),
                              const SizedBox(height: 24),
                              PrimaryButton(
                                text: 'Editar Perfil',
                                onPressed: _navigateToEdit,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: AppColors.bgPage,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Mi Perfil',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.accentGreen),
            onPressed: _navigateToEdit,
          ),
        ],
      ),
    );
  }

  // ─── Avatar ─────────────────────────────────────────────────────────────────

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentGreen, width: 3),
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.surface,
              backgroundImage: _controller.profileImageUrl != null
                  ? NetworkImage(_controller.profileImageUrl!)
                  : null,
              child: _controller.profileImageUrl == null
                  ? const Icon(
                      Icons.person_outline,
                      size: 36,
                      color: AppColors.textSecondary,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${_controller.firstName ?? ''} ${_controller.lastName ?? ''}'
                .trim(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          if (_controller.role != null) _buildRoleBadge(_controller.role!),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentGreenBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _roleLabel(role),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.positiveDeltaText,
        ),
      ),
    );
  }

  // ─── Card de información personal ──────────────────────────────────────────

  Widget _buildSectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.accentGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppBorders.defaultRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.badge_outlined, 'Nombre', _controller.firstName),
          _buildDivider(),
          _buildInfoRow(Icons.badge_outlined, 'Apellido', _controller.lastName),
          _buildDivider(),
          _buildInfoRow(
            Icons.mail_outline,
            'Correo electrónico',
            _controller.email,
          ),
          _buildDivider(),
          _buildInfoRow(Icons.lock_outline, 'Contraseña', '••••••••'),
          _buildDivider(),
          _buildInfoRow(
            Icons.shield_outlined,
            'Rol',
            null,
            badge: _controller.role != null
                ? _roleLabel(_controller.role!)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String? value, {
    String? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreenBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.positiveDeltaText,
                      ),
                    ),
                  )
                else
                  Text(
                    value ?? '—',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: value != null
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      const Divider(height: 1, thickness: 1, color: AppColors.border);

  // ─── Navegación ─────────────────────────────────────────────────────────────

  Future<void> _navigateToEdit() async {
    final updated = await Navigator.pushNamed(context, '/edit-profile');
    if (updated == true) {
      await _controller.refresh();
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String _roleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'tecnico':
        return 'Técnico';
      case 'directivo':
        return 'Directivo';
      case 'serviciosgenerales':
        return 'Servicios Generales';
      default:
        return role;
    }
  }
}
