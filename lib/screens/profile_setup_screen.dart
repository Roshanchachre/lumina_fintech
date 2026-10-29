import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/account_bloc.dart';
import '../core/sound/sound_service.dart';
import '../models/account_models.dart';
import '../theme/lumina_theme.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/lumina_snackbar.dart';
import 'main_shell_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final UserProfile initialUser;
  final bool isInitialSetup;

  const ProfileSetupScreen({
    super.key,
    required this.initialUser,
    this.isInitialSetup = true,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;

  late TabController _tabController;
  late String _selectedAvatarUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialUser.name);
    _phoneController = TextEditingController(text: widget.initialUser.phoneNumber);
    _bioController = TextEditingController(text: widget.initialUser.bio);
    _selectedAvatarUrl = widget.initialUser.avatarUrl.isNotEmpty
        ? widget.initialUser.avatarUrl
        : 'assets/avatars/boy_1.png';
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onAvatarSelected(AvatarItem avatar) {
    SoundService.instance.play(LuminaSound.cardClick);
    HapticFeedback.selectionClick();
    setState(() {
      _selectedAvatarUrl = avatar.assetPath;
    });
    context.read<AuthBloc>().add(SelectAvatar(avatar.assetPath));
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      SoundService.instance.play(LuminaSound.errorAlert);
      HapticFeedback.heavyImpact();
      return;
    }

    SoundService.instance.play(LuminaSound.cardClick);
    HapticFeedback.mediumImpact();

    context.read<AuthBloc>().add(
          UpdateProfileRequested(
            fullName: _nameController.text.trim(),
            avatarUrl: _selectedAvatarUrl,
            phoneNumber: _phoneController.text.trim(),
            bio: _bioController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated && state.user != null) {
          SoundService.instance.play(LuminaSound.biometricUnlock);
          HapticFeedback.heavyImpact();
          // Reload AccountBloc so all screens receive the new user profile & avatar immediately
          context.read<AccountBloc>().add(LoadAccountData());

          LuminaSnackBar.show(
            context,
            type: LuminaSnackBarType.success,
            title: 'Identity Confirmed',
            message: 'Profile and avatar preferences successfully saved to vault.',
          );

          if (widget.isInitialSetup) {
            Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const MainShellScreen(),
                transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
              ),
              (route) => false,
            );
          } else {
            Navigator.of(context).pop();
          }
        } else if (state.status == AuthStatus.error && state.errorMessage != null) {
          LuminaSnackBar.show(
            context,
            type: LuminaSnackBarType.error,
            title: 'Profile Error',
            message: state.errorMessage!,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;
        final allAvatars = state.availableAvatars.isNotEmpty
            ? state.availableAvatars
            : AvatarItem.defaults;

        final boyAvatars = allAvatars.where((a) => a.gender == 'boy').toList();
        final girlAvatars = allAvatars.where((a) => a.gender == 'girl').toList();

        final currentAvatarItem = allAvatars.firstWhere(
          (a) => a.assetPath == _selectedAvatarUrl,
          orElse: () => allAvatars.first,
        );

        return Scaffold(
          backgroundColor: LuminaColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: widget.isInitialSetup
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: LuminaColors.textPrimary, size: 18),
                    onPressed: () {
                      SoundService.instance.play(LuminaSound.cardClick);
                      Navigator.of(context).pop();
                    },
                  ),
            title: Text(
              widget.isInitialSetup ? 'INITIALIZE PROFILE' : 'EDIT SOVEREIGN PROFILE',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: LuminaColors.textPrimary,
              ),
            ),
            centerTitle: true,
          ),
          body: LuminaAtmosphericBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // HERO AVATAR DISPLAY
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glowing background halo
                                Container(
                                  width: 124,
                                  height: 124,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LuminaColors.cobaltAcid,
                                    boxShadow: [
                                      BoxShadow(
                                        color: LuminaColors.electricCobalt.withValues(alpha: 0.4),
                                        blurRadius: 28,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                // Avatar circle container
                                Container(
                                  width: 114,
                                  height: 114,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF030407),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      _selectedAvatarUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person_rounded,
                                        color: LuminaColors.acidLime,
                                        size: 56,
                                      ),
                                    ),
                                  ),
                                ),
                                // Verified Badge / Edit Indicator
                                Positioned(
                                  bottom: 0,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: LuminaColors.acidLime,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: LuminaColors.background, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 14,
                                      color: Color(0xFF030407),
                                    ),
                                  ),
                                ),
                              ],
                            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

                            const SizedBox(height: 14),

                            Text(
                              currentAvatarItem.name.toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: LuminaColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${currentAvatarItem.style} • ${currentAvatarItem.gender == "boy" ? "Male Persona" : "Female Persona"}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: LuminaColors.acidLime,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // AVATAR CATALOGUE SELECTOR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'SELECT PREDEFINED AVATAR',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: LuminaColors.electricCobalt,
                                letterSpacing: 1.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '8 Available Characters',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: LuminaColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Tab Filter (All, Boys, Girls)
                      Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: LuminaColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: LuminaColors.surfaceBorder),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: LuminaColors.electricCobalt,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: Colors.white,
                          unselectedLabelColor: LuminaColors.textMuted,
                          labelStyle: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700),
                          tabs: const [
                            Tab(text: 'ALL CHARACTERS'),
                            Tab(text: 'BOYS'),
                            Tab(text: 'GIRLS'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Avatar Grid in TabBarView
                      SizedBox(
                        height: 210,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAvatarGrid(allAvatars),
                            _buildAvatarGrid(boyAvatars),
                            _buildAvatarGrid(girlAvatars),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // PROFILE FORM FIELDS
                      Text(
                        'DISPLAY / LEGAL NAME',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: LuminaColors.electricCobalt,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        style: GoogleFonts.plusJakartaSans(
                          color: LuminaColors.textPrimary,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Alex Vance',
                          prefixIcon: const Icon(
                            Icons.badge_outlined,
                            color: LuminaColors.textMuted,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: LuminaColors.surfaceElevated,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Legal name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      Text(
                        'INSTITUTIONAL EMAIL',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: LuminaColors.electricCobalt,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: LuminaColors.surfaceElevated.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              color: LuminaColors.electricCobalt,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.initialUser.email,
                                style: GoogleFonts.plusJakartaSans(
                                  color: LuminaColors.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: LuminaColors.acidLime.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'VERIFIED',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: LuminaColors.acidLime,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        'SECURE PHONE NUMBER (OPTIONAL)',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: LuminaColors.electricCobalt,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.plusJakartaSans(
                          color: LuminaColors.textPrimary,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: '+1 (555) 019-2834',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: LuminaColors.textMuted.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            color: LuminaColors.textMuted,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: LuminaColors.surfaceElevated,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        'SOVEREIGN BIO & TAGLINE',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: LuminaColors.electricCobalt,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 2,
                        style: GoogleFonts.plusJakartaSans(
                          color: LuminaColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Web3 Builder, Quantitative Trader & Sovereign Vault Holder',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: LuminaColors.textMuted.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: LuminaColors.surfaceElevated,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        ),
                      ),

                      const SizedBox(height: 32),

                      // SAVE BUTTON
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _saveProfile,
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
                                        widget.isInitialSetup ? 'COMPLETE & ENTER VAULT' : 'SAVE PROFILE CHANGES',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_rounded, size: 18),
                                    ],
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),
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

  Widget _buildAvatarGrid(List<AvatarItem> avatars) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        final avatar = avatars[index];
        final isSelected = avatar.assetPath == _selectedAvatarUrl;

        return GestureDetector(
          onTap: () => _onAvatarSelected(avatar),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 130,
            margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? LuminaColors.electricCobalt.withValues(alpha: 0.18)
                  : LuminaColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? LuminaColors.acidLime : LuminaColors.surfaceBorder,
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: LuminaColors.acidLime.withValues(alpha: 0.25),
                        blurRadius: 12,
                      )
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? LuminaColors.acidLime : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          avatar.assetPath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person_rounded,
                            color: LuminaColors.textMuted,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: LuminaColors.acidLime,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Color(0xFF030407),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  avatar.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? LuminaColors.acidLime : LuminaColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  avatar.style,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: LuminaColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
