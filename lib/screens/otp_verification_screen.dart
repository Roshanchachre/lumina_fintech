import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/account_bloc.dart';
import '../core/sound/sound_service.dart';
import '../theme/lumina_theme.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/lumina_snackbar.dart';
import 'main_shell_screen.dart';
import 'profile_setup_screen.dart';
import 'reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String type; // 'register' | 'reset'

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.type = 'register',
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Handles pasting full 6 digits
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (int i = 0; i < 6 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      if (digits.length >= 6) {
        _focusNodes[5].requestFocus();
        _verifyCode();
      } else {
        _focusNodes[digits.length].requestFocus();
      }
      return;
    }

    if (value.isNotEmpty) {
      SoundService.instance.play(LuminaSound.cardClick);
      HapticFeedback.selectionClick();
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_otpCode.length == 6) {
          _verifyCode();
        }
      }
    }
  }

  void _onKeyDown(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verifyCode() {
    FocusScope.of(context).unfocus();
    final code = _otpCode;
    if (code.length != 6) {
      SoundService.instance.play(LuminaSound.errorAlert);
      HapticFeedback.heavyImpact();
      LuminaSnackBar.show(
        context,
        type: LuminaSnackBarType.warning,
        title: 'Incomplete Code',
        message: 'Please enter the full 6-digit verification code.',
      );
      return;
    }

    SoundService.instance.play(LuminaSound.cardClick);
    HapticFeedback.mediumImpact();

    context.read<AuthBloc>().add(
          VerifyOtpRequested(
            email: widget.email,
            otp: code,
            type: widget.type,
          ),
        );
  }

  void _resendCode() {
    SoundService.instance.play(LuminaSound.wireSend);
    HapticFeedback.mediumImpact();
    context.read<AuthBloc>().add(
          ResendOtpRequested(
            email: widget.email,
            type: widget.type,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated && state.user != null) {
          SoundService.instance.play(LuminaSound.biometricUnlock);
          context.read<AccountBloc>().add(LoadAccountData());
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const MainShellScreen(),
              transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            ),
            (route) => false,
          );
        } else if (state.status == AuthStatus.profileIncomplete && state.user != null) {
          SoundService.instance.play(LuminaSound.biometricUnlock);
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ProfileSetupScreen(initialUser: state.user!),
              transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            ),
          );
        } else if (state.status == AuthStatus.passwordResetSent && widget.type == 'reset') {
          SoundService.instance.play(LuminaSound.cardClick);
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ResetPasswordScreen(
                email: widget.email,
                verifiedOtp: _otpCode,
              ),
              transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            ),
          );
        } else if (state.status == AuthStatus.error && state.errorMessage != null) {
          SoundService.instance.play(LuminaSound.errorAlert);
          HapticFeedback.heavyImpact();
          LuminaSnackBar.show(
            context,
            type: LuminaSnackBarType.error,
            title: 'Verification Failed',
            message: state.errorMessage!,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;
        final resendCountdown = state.resendCountdown;
        final canResend = resendCountdown <= 0;

        return Scaffold(
          backgroundColor: LuminaColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: LuminaColors.textPrimary, size: 18),
              onPressed: () {
                SoundService.instance.play(LuminaSound.cardClick);
                Navigator.of(context).pop();
              },
            ),
          ),
          body: LuminaAtmosphericBackground(
            showFloatingBoxes: true,
            pulseIntensity: 1.0,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Lock/Mail Monogram Icon
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
                                spreadRadius: 2,
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
                                Icons.mark_email_read_rounded,
                                color: LuminaColors.acidLime,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

                      const SizedBox(height: 20),

                      Text(
                        widget.type == 'reset'
                            ? 'VERIFY RESET CIPHER'
                            : 'SECURITY VERIFICATION',
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
                        'We have dispatched a 6-digit cryptographic verification code to:',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: LuminaColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.email,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: LuminaColors.acidLime,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // 6 Digits Input Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final boxSize = ((constraints.maxWidth - (5 * 8)) / 6).clamp(36.0, 52.0);
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return KeyboardListener(
                                focusNode: FocusNode(),
                                onKeyEvent: (e) => _onKeyDown(index, e),
                                child: Container(
                                  width: boxSize,
                                  height: boxSize * 1.25,
                                  decoration: BoxDecoration(
                                    color: LuminaColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _controllers[index].text.isNotEmpty
                                          ? LuminaColors.electricCobalt
                                          : LuminaColors.surfaceBorder,
                                      width: _controllers[index].text.isNotEmpty ? 1.5 : 1.0,
                                    ),
                                    boxShadow: _controllers[index].text.isNotEmpty
                                        ? [
                                            BoxShadow(
                                              color: LuminaColors.electricCobalt.withValues(alpha: 0.2),
                                              blurRadius: 8,
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: TextField(
                                      controller: _controllers[index],
                                      focusNode: _focusNodes[index],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(6),
                                      ],
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: LuminaColors.textPrimary,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        counterText: '',
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (val) => _onDigitChanged(index, val),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Verify Button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _verifyCode,
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
                                        'VERIFY CREDENTIAL',
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

                      const SizedBox(height: 24),

                      // Resend Code Row
                      Center(
                        child: canResend
                            ? GestureDetector(
                                onTap: _resendCode,
                                child: Text(
                                  'Resend Verification Code',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: LuminaColors.acidLime,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.timer_outlined,
                                    color: LuminaColors.textMuted,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Resend code in ${resendCountdown}s',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      color: LuminaColors.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      const SizedBox(height: 16),
                    ],
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
