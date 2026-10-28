import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/lumina_theme.dart';
import 'dashboard_screen.dart';
import 'cards_screen.dart';
import 'portfolio_screen.dart';
import 'settings_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _activeNavIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    CardsScreen(),
    PortfolioScreen(),
    SettingsScreen(),
  ];

  void _onTabSelected(int index) {
    if (_activeNavIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _activeNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: Stack(
        children: [
          // IndexedStack preserves scroll position & 3D state of each tab
          IndexedStack(
            index: _activeNavIndex,
            children: _screens,
          ),

          // Floating Glass Capsule Dock (Bottom Nav)
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomInset > 0 ? bottomInset + 6 : 18,
            child: _buildFloatingDock().animate().fadeIn(delay: 400.ms).slideY(begin: 0.5, end: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingDock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceElevated.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: LuminaColors.surfaceBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: LuminaColors.electricCobalt.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _dockItem(0, Icons.home_filled, 'Home'),
          _dockItem(1, Icons.credit_card_rounded, 'Cards'),
          _dockItem(2, Icons.pie_chart_rounded, 'Portfolio'),
          _dockItem(3, Icons.tune_rounded, 'Settings'),
        ],
      ),
    );
  }

  Widget _dockItem(int index, IconData icon, String label) {
    final isSelected = _activeNavIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? LuminaColors.electricCobalt.withValues(alpha: 0.22)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: LuminaColors.electricCobalt.withValues(alpha: 0.4), width: 1)
                : null,
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? LuminaColors.acidLime : LuminaColors.textMuted,
                    size: 22,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: LuminaColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
