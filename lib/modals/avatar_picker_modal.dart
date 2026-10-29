import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth_bloc.dart';
import '../core/sound/sound_service.dart';
import '../models/account_models.dart';
import '../theme/lumina_theme.dart';

class AvatarPickerModal extends StatefulWidget {
  final String currentAvatarUrl;
  final Function(String newAvatarUrl) onAvatarSelected;

  const AvatarPickerModal({
    super.key,
    required this.currentAvatarUrl,
    required this.onAvatarSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required String currentAvatarUrl,
    required Function(String newAvatarUrl) onAvatarSelected,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AvatarPickerModal(
        currentAvatarUrl: currentAvatarUrl,
        onAvatarSelected: onAvatarSelected,
      ),
    );
  }

  @override
  State<AvatarPickerModal> createState() => _AvatarPickerModalState();
}

class _AvatarPickerModalState extends State<AvatarPickerModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _selectedUrl;

  @override
  void initState() {
    super.initState();
    _selectedUrl = widget.currentAvatarUrl;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final allAvatars = authState.availableAvatars.isNotEmpty
            ? authState.availableAvatars
            : AvatarItem.defaults;
        final boyAvatars = allAvatars.where((a) => a.gender == 'boy').toList();
        final girlAvatars = allAvatars.where((a) => a.gender == 'girl').toList();

        return Container(
          decoration: const BoxDecoration(
            color: LuminaColors.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: LuminaColors.surfaceBorder, width: 1.5),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LuminaColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHOOSE AVATAR PERSONA',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: LuminaColors.textPrimary,
                          ),
                        ),
                        Text(
                          '8 Distinct hand-crafted styles',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: LuminaColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: LuminaColors.textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Filter Tabs
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D121D),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: LuminaColors.electricCobalt,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: LuminaColors.textMuted,
                    labelStyle: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700),
                    tabs: const [
                      Tab(text: 'ALL (8)'),
                      Tab(text: 'BOYS (4)'),
                      Tab(text: 'GIRLS (4)'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Grid View
                SizedBox(
                  height: 250,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGrid(allAvatars),
                      _buildGrid(boyAvatars),
                      _buildGrid(girlAvatars),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      SoundService.instance.play(LuminaSound.biometricUnlock);
                      HapticFeedback.mediumImpact();
                      widget.onAvatarSelected(_selectedUrl);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LuminaColors.acidLime,
                      foregroundColor: const Color(0xFF030407),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'APPLY AVATAR',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
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

  Widget _buildGrid(List<AvatarItem> avatars) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.76,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        final avatar = avatars[index];
        final isSelected = avatar.assetPath == _selectedUrl;

        return GestureDetector(
          onTap: () {
            SoundService.instance.play(LuminaSound.cardClick);
            HapticFeedback.selectionClick();
            setState(() {
              _selectedUrl = avatar.assetPath;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected
                  ? LuminaColors.electricCobalt.withValues(alpha: 0.2)
                  : const Color(0xFF0D121D),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? LuminaColors.acidLime : LuminaColors.surfaceBorder,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ClipOval(
                    child: Image.asset(
                      avatar.assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  avatar.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? LuminaColors.acidLime : LuminaColors.textPrimary,
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
