import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/core/constants/app_palette.dart';
import 'package:visioncare_app/enums/theme_preference_enum.dart';
import 'package:visioncare_app/presentation/login/viewmodel/login_view_model.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/speech_view_model.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/text_scale_notifier.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/theme_preference_notifier.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/tts_view_model.dart';
import 'package:visioncare_app/presentation/shared/voice/email_dictation_handler.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _passwordHidden = true;
  bool _dictationUsed = false;
  AppPalette _palette = AppPalette.light;

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(loginViewModelProvider);
    final scale = ref.watch(textScaleProvider);
    final isReading = ref.watch(ttsViewModelProvider).isPlaying;
    // El reconocimiento de voz se crea al tocar el microfono, asi el permiso se pide recien ahi
    final isDictating = _dictationUsed && ref.watch(speechViewModelProvider).isListening;
    _palette = AppPalette.resolve(
      ref.watch(themePreferenceProvider),
      MediaQuery.platformBrightnessOf(context),
    );

    if (!vm.isLoading && vm.loginSuccessful) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.pushReplacement('/home');
      });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _palette.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _palette.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(vm, isReading, scale),
                      const SizedBox(height: 26),
                      Text('VisionCare', style: _titleStyle(20 * scale)),
                      const SizedBox(height: 4),
                      Semantics(
                        header: true,
                        child: Text('Inicia sesión', style: _titleStyle(34 * scale)),
                      ),
                      const SizedBox(height: 26),
                      _buildLabel('Correo electrónico', scale),
                      const SizedBox(height: 10),
                      Semantics(
                        label: 'Correo electrónico',
                        child: TextField(
                          controller: vm.emailController,
                          enabled: !vm.isLoading,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => vm.clearError(),
                          style: _fieldStyle(scale),
                          cursorColor: _palette.focus,
                          decoration: _fieldDecoration(
                            hasError: false,
                            suffix: _buildFieldButton(
                              icon: isDictating ? Icons.stop : Icons.mic_none,
                              label: isDictating ? 'Detener el dictado' : 'Dictar el correo por voz',
                              filled: true,
                              onPressed: () => _toggleDictation(vm),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      _buildLabel('Contraseña', scale),
                      const SizedBox(height: 10),
                      Semantics(
                        label: 'Contraseña',
                        child: TextField(
                          controller: vm.passwordController,
                          enabled: !vm.isLoading,
                          obscureText: _passwordHidden,
                          keyboardType: TextInputType.visiblePassword,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => vm.clearError(),
                          onSubmitted: (_) => vm.login(),
                          style: _fieldStyle(scale),
                          cursorColor: _palette.focus,
                          decoration: _fieldDecoration(
                            hasError: vm.hasBadLogin,
                            suffix: _buildFieldButton(
                              icon: _passwordHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              label: _passwordHidden ? 'Mostrar la contraseña' : 'Ocultar la contraseña',
                              filled: false,
                              onPressed: () => setState(() => _passwordHidden = !_passwordHidden),
                            ),
                          ),
                        ),
                      ),
                      if (vm.hasBadLogin) ...[
                        const SizedBox(height: 12),
                        _buildError(vm.errorMessage, scale),
                      ],
                      const SizedBox(height: 28),
                      _buildLoginButton(vm, scale),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: vm.isLoading ? null : () => context.push('/register'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _palette.secondaryAction,
                          minimumSize: const Size.fromHeight(60),
                          side: BorderSide(color: _palette.secondaryAction, width: 3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          'Crear cuenta nueva',
                          textAlign: TextAlign.center,
                          style: _buttonStyle(20 * scale, _palette.secondaryAction),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LoginViewModel vm, bool isReading, double scale) {
    final themeLabel = _palette.isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro';
    return Row(
      children: [
        Image.asset('assets/images/logo_app.png', width: 48, height: 48, semanticLabel: 'Logo de VisionCare'),
        const Spacer(),
        Tooltip(
          message: themeLabel,
          child: OutlinedButton(
            onPressed: () => ref
                .read(themePreferenceProvider.notifier)
                .set(_palette.isDark ? ThemePreference.light : ThemePreference.dark),
            style: OutlinedButton.styleFrom(
              foregroundColor: _palette.text,
              minimumSize: const Size(56, 56),
              padding: EdgeInsets.zero,
              side: BorderSide(color: _palette.border, width: 3),
              shape: const CircleBorder(),
            ),
            child: Icon(_palette.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 26),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: () => _toggleReading(vm, isReading),
          icon: Icon(isReading ? Icons.stop : Icons.volume_up_outlined, size: 24),
          label: Text(isReading ? 'Detener' : 'Escuchar', style: _buttonStyle(17 * scale, _palette.text)),
          style: OutlinedButton.styleFrom(
            foregroundColor: _palette.text,
            minimumSize: const Size(0, 56),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            side: BorderSide(color: _palette.border, width: 3),
            shape: const StadiumBorder(),
          ),
        ),
      ],
    );
  }

  // Lee en voz alta que hay en la pantalla y, si lo hay, el error
  void _toggleReading(LoginViewModel vm, bool isReading) {
    final tts = ref.read(ttsViewModelProvider);
    if (isReading) {
      tts.setStopHandler();
      return;
    }
    final text = StringBuffer(
      'Pantalla para iniciar sesión en VisionCare. '
      'Escribe tu correo electrónico o díctalo con el botón del micrófono. '
      'Luego escribe tu contraseña y toca el botón Entrar, al final de la pantalla. '
      'Si no tienes cuenta, toca Crear cuenta nueva.',
    );
    if (vm.hasBadLogin) text.write(' Atención: ${vm.errorMessage}');
    tts.setStartHandler(text.toString());
  }

  Future<void> _toggleDictation(LoginViewModel vm) async {
    if (!_dictationUsed) setState(() => _dictationUsed = true);
    final speech = ref.read(speechViewModelProvider);
    if (!speech.isAvailable) await speech.initialize();
    if (!mounted) return;
    if (!speech.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El dictado por voz no está disponible en este teléfono')),
      );
      return;
    }
    if (speech.isListening) {
      speech.stopListening();
      return;
    }
    vm.clearError();
    speech.setCommandHandler(EmailDictationHandler(), context, controller: vm.emailController);
    speech.startListening();
  }

  Widget _buildLabel(String text, double scale) {
    // El lector de pantalla ya lee la etiqueta desde el campo
    return ExcludeSemantics(
      child: Text(
        text,
        style: GoogleFonts.openSans(
          textStyle: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold, color: _palette.text),
        ),
      ),
    );
  }

  Widget _buildError(String message, double scale) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _palette.errorBackground,
          border: Border.all(color: _palette.errorBorder, width: 3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: _palette.errorText, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    fontSize: 17 * scale,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: _palette.errorText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(LoginViewModel vm, double scale) {
    return ValueListenableBuilder<bool>(
      valueListenable: vm.isLoginButtonEnabled,
      builder: (context, isEnabled, child) {
        return ElevatedButton(
          // Mientras carga se mantiene verde y no hace nada, para que el estado se lea bien
          onPressed: !isEnabled ? null : (vm.isLoading ? () {} : () => vm.login()),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.textColor,
            disabledBackgroundColor: _palette.disabled,
            disabledForegroundColor: _palette.disabledText,
            minimumSize: const Size.fromHeight(60),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: vm.isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.textColor),
                    ),
                    const SizedBox(width: 14),
                    Flexible(child: Text('Comprobando tu cuenta', style: _buttonStyle(19 * scale, AppColors.textColor))),
                  ],
                )
              : Text('Entrar', style: _buttonStyle(22 * scale, null)),
        );
      },
    );
  }

  Widget _buildFieldButton({
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: filled ? AppColors.primaryColor : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: filled ? BorderSide.none : BorderSide(color: _palette.border, width: 2),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onPressed,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(icon, size: 26, color: filled ? AppColors.textColor : _palette.text),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({required bool hasError, Widget? suffix}) {
    final borderColor = hasError ? _palette.errorBorder : _palette.border;
    return InputDecoration(
      filled: true,
      fillColor: _palette.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      suffixIcon: suffix,
      suffixIconConstraints: const BoxConstraints(minWidth: 56, minHeight: 48),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 3),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _palette.disabled, width: 3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: hasError ? _palette.errorBorder : _palette.focus, width: 3),
      ),
    );
  }

  TextStyle _titleStyle(double size) {
    return GoogleFonts.ptSans(
      textStyle: TextStyle(fontSize: size, fontWeight: FontWeight.bold, height: 1.05, color: _palette.text),
    );
  }

  TextStyle _fieldStyle(double scale) {
    return GoogleFonts.openSans(
      textStyle: TextStyle(fontSize: 20 * scale, color: _palette.text),
    );
  }

  TextStyle _buttonStyle(double size, Color? color) {
    return GoogleFonts.openSans(
      textStyle: TextStyle(fontSize: size, fontWeight: FontWeight.bold, color: color),
    );
  }
}
