import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth_bloc.dart';
import '../core/sound/sound_service.dart';
import '../theme/lumina_theme.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/lumina_snackbar.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String verifiedOtp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.verifiedOtp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  double _passwordStrength = 0.0;
  String _strengthLabel = 'Enter password';
  Color _strengthColor = LuminaColors.textMuted;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_evalPasswordStrength);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_evalPasswordStrength);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _evalPasswordStrength() {
    final text = _passwordController.text;
    if (text.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _strengthLabel = 'Enter password';
        _strengthColor = LuminaColors.textMuted;
      });
      return;
    }

    double strength = 0.0;
    if (text.length >= 6) strength += 0.3;
    if (text.length >= 10) strength += 0.2;
    if (RegExp(r'[A-Z]').hasMatch(text)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(text)) strength += 0.15;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(text)) strength += 0.15;

    String label;
    Color color;
    if (strength <= 0.3) {
      label = 'Weak Cipher';
      color = LuminaColors.crimsonAlert;
    } else if (strength <= 0.7) {
      label = 'Moderate Protection';
      color = const Color(0xFFFFB800);
    } else {
      label = 'Bank-Grade Strong';
      color = LuminaColors.acidLime;
    }

    setState(() {
      _passwordStrength = strength.clamp(0.0, 1.0);
      _strengthLabel = label;
      _strengthColor = color;
    });
  }

  void _submitReset() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      SoundService.instance.play(LuminaSound.errorAlert);
      HapticFeedback.heavyImpact();
      return;
    }

    SoundService.instance.play(LuminaSound.cardClick);
    HapticFeedback.mediumImpact();

    context.read<AuthBloc>().add(
          ResetPasswordRequested(
            email: widget.email,
            otp: widget.verifiedOtp,
            newPassword: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.passwordResetSuccess) {
          LuminaSnackBar.show(
            context,
            type: LuminaSnackBarType.success,
            title: 'Cipher Reconfigured',
            message: state.infoMessage ?? 'Password updated! Please log in with your new credentials.',
          );
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const LoginScreen(),
              transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            ),
            (route) => false,
          );
        } else if (state.status == AuthStatus.error && state.errorMessage != null) {
          LuminaSnackBar.show(
            context,
            type: LuminaSnackBarType.error,
            title: 'Reset Error',
            message: state.errorMessage!,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;

        return Scaffold(
          backgroundColor: LuminaColors.background,
          body: LuminaAtmosphericBackground(
            showFloatingBoxes: true,
            pulseIntensity: 1.0,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: LuminaColors.cobaltAcid,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: LuminaColors.electricCobalt.withValues(alpha: 0.35),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 58,
                                height: 58,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF030407),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.vpn_key_rounded,
                                  color: LuminaColors.acidLime,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

                        const SizedBox(height: 20),

                        Text(
                          'ENTER NEW CIPHER',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: LuminaColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a strong security cipher for ${widget.email}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: LuminaColors.textMuted,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Password Field
                        Text(
                          'NEW CIPHER KEY',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: LuminaColors.electricCobalt,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.plusJakartaSans(
                            color: LuminaColors.textPrimary,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Minimum 6 characters',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              color: LuminaColors.textMuted.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: LuminaColors.textMuted,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: LuminaColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: LuminaColors.surfaceElevated,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: LuminaColors.surfaceBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: LuminaColors.surfaceBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: LuminaColors.electricCobalt, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: LuminaColors.crimsonAlert),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        // Strength bar
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _passwordStrength,
                                  backgroundColor: LuminaColors.surfaceBorder,
                                  valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _strengthLabel,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _strengthColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Confirm Password
                        Text(
                          'CONFIRM NEW CIPHER',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: LuminaColors.electricCobalt,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          style: GoogleFonts.plusJakartaSans(
                            color: LuminaColors.textPrimary,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Re-enter new cipher',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              color: LuminaColors.textMuted.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.verified_user_outlined,
                              color: LuminaColors.textMuted,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: LuminaColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirm = !_obscureConfirm;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: LuminaColors.surfaceElevated,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: LuminaColors.surfaceBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: LuminaColors.surfaceBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: LuminaColors.electricCobalt, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: LuminaColors.crimsonAlert),
                            ),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submitReset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LuminaColors.electricCobalt,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: LuminaColors.electricCobalt.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'CONFIRM & UPDATE CIPHER',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.check_circle_outline_rounded, size: 18),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
