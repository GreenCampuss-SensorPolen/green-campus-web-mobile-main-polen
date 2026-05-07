import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_borders.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/logic/profile/edit_profile_controller.dart';
import 'package:mobile_app/widgets/password_text_field.dart';
import 'package:mobile_app/widgets/primary_button.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final EditProfileController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = EditProfileController();
    _controller.init();
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (!mounted) return;

    if (_controller.success) {
      Navigator.pop(context, true);
      return;
    }

    if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage!),
          backgroundColor: AppColors.statusOffline,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.bgPage,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                    child: Form(
                      key: _formKey,
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
                          _buildRequiredCard(),
                          const SizedBox(height: 24),
                          PrimaryButton(
                            text: 'Guardar Cambios',
                            isLoading: _controller.isLoading,
                            onPressed: _submit,
                          ),
                        ],
                      ),
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
              'Editar Perfil',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.accentGreen),
            onPressed: _controller.isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }

  // ─── Avatar ─────────────────────────────────────────────────────────────────

  Widget _buildAvatarSection() {
    return Center(
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accentGreen, width: 3),
        ),
        child: const CircleAvatar(
          radius: 42,
          backgroundColor: AppColors.surface,
          child: Icon(
            Icons.person_outline,
            size: 36,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ─── Sección label ──────────────────────────────────────────────────────────

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

  // ─── Tarjeta de campos requeridos ────────────────────────────────────────────

  Widget _buildRequiredCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorders.defaultRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _controller.firstNameController,
            label: 'Nombre',
            hint: 'Tu nombre',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _controller.lastNameController,
            label: 'Apellido',
            hint: 'Tu apellido',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'El apellido es obligatorio' : null,
          ),
          const SizedBox(height: 20),
          PasswordTextField(
            controller: _controller.passwordController,
            label: 'Nueva contraseña',
            hintText: 'Nueva contraseña...',
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Déjala en blanco para no cambiarla',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Widget auxiliar de campo de texto ───────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            filled: true,
            fillColor: AppColors.bgPage,
            border: OutlineInputBorder(
              borderRadius: AppBorders.defaultRadius,
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppBorders.defaultRadius,
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppBorders.defaultRadius,
              borderSide: const BorderSide(
                color: AppColors.accentGreen,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppBorders.defaultRadius,
              borderSide: const BorderSide(color: AppColors.statusOffline),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Acciones ───────────────────────────────────────────────────────────────

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _controller.saveChanges();
    }
  }
}
