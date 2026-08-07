import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Pantalla de registro. Diseño adaptado del frontend_/ original.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthRegister(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          showErrorSnack(context, state.message);
        }
        if (state is AuthRegistered) {
          showSuccessSnack(context, state.message);
          context.pop(); // volver al login
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE8EEF8),
                Color(0xFFD6E3FA),
                Color(0xFFEBF2FF),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildForm(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.primary),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Icon(Icons.shield_rounded,
            size: 48, color: AppColors.primary),
        SizedBox(height: 12),
        Text('Crear cuenta', style: AppTextStyles.heading1),
        SizedBox(height: 4),
        Text(
          'Completa los datos para registrarte',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outlined),
                labelText: 'Nombre completo',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ingresa tu nombre' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
                labelText: 'Correo electrónico',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                if (!v.contains('@')) return 'Correo inválido';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outlined),
                labelText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                if (v.length < 6) return 'Mínimo 6 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outlined),
                labelText: 'Confirmar contraseña',
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (v) {
                if (v != _passwordCtrl.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) => LoadingButton(
                onPressed: _submit,
                label: 'Crear Cuenta',
                isLoading: state is AuthLoading,
                icon: Icons.person_add_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
