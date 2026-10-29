import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/services/notification_service.dart';
import '../core/sound/sound_service.dart';
import '../theme/lumina_theme.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/lumina_snackbar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationCategory _selectedCategory = NotificationCategory.all;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    NotificationService.instance.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  List<VaultNotification> get _notifications => NotificationService.instance.notifications;

  List<VaultNotification> get _filteredNotifications {
    if (_selectedCategory == NotificationCategory.all) {
      return _notifications;
    }
    return _notifications.where((n) => n.category == _selectedCategory).toList();
  }

  void _markAllAsRead() {
    HapticFeedback.mediumImpact();
    SoundService.instance.play(LuminaSound.cardClick);
    NotificationService.instance.markAllAsRead();
    LuminaSnackBar.show(
      context,
      type: LuminaSnackBarType.success,
      title: 'Ledger Synced',
      message: 'All vault notifications marked as read.',
    );
  }

  void _clearNotification(String id) {
    HapticFeedback.lightImpact();
    NotificationService.instance.removeNotification(id);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications;
    final unreadCount = _notifications.where((n) => !n.isRead).length;

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
        title: Text(
          'VAULT NOTIFICATIONS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: LuminaColors.textPrimary,
          ),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'MARK READ',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: LuminaColors.acidLime,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: LuminaAtmosphericBackground(
        showGrid: true,
        child: SafeArea(
          child: Column(
            children: [
              // Category Filter Tabs
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', NotificationCategory.all, _notifications.length),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'YIELDS',
                        NotificationCategory.yields,
                        _notifications.where((n) => n.category == NotificationCategory.yields).length,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'TRANSFERS',
                        NotificationCategory.transfers,
                        _notifications.where((n) => n.category == NotificationCategory.transfers).length,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'SECURITY',
                        NotificationCategory.security,
                        _notifications.where((n) => n.category == NotificationCategory.security).length,
                      ),
                    ],
                  ),
                ),
              ),

              // Summary Status Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: LuminaColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: LuminaColors.surfaceBorderSubtle),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: unreadCount > 0 ? LuminaColors.acidLime : LuminaColors.textMuted,
                          boxShadow: unreadCount > 0
                              ? [
                                  BoxShadow(
                                    color: LuminaColors.acidLime.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          unreadCount > 0 ? '$unreadCount UNREAD DISPATCHES' : 'ALL DISPATCHES READ',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: LuminaColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SWIPE TO DISMISS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: LuminaColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Notifications List
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final notif = filtered[index];
                          return Dismissible(
                            key: ValueKey(notif.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _clearNotification(notif.id),
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: LuminaColors.crimsonAlert.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: LuminaColors.crimsonAlert.withValues(alpha: 0.4)),
                              ),
                              alignment: Alignment.centerRight,
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: LuminaColors.crimsonAlert,
                                size: 24,
                              ),
                            ),
                            child: _buildNotificationCard(notif, index),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, NotificationCategory cat, int count) {
    final isSelected = _selectedCategory == cat;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedCategory = cat;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? LuminaColors.acidLime : LuminaColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? LuminaColors.acidLime : LuminaColors.surfaceBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: isSelected ? LuminaColors.midnightBlack : LuminaColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? LuminaColors.midnightBlack.withValues(alpha: 0.2)
                    : LuminaColors.surfaceBorderSubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? LuminaColors.midnightBlack : LuminaColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(VaultNotification notif, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        NotificationService.instance.markAsRead(notif.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead
              ? LuminaColors.surfaceElevated.withValues(alpha: 0.6)
              : LuminaColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: notif.isRead
                ? LuminaColors.surfaceBorderSubtle
                : notif.accentColor.withValues(alpha: 0.4),
            width: notif.isRead ? 1 : 1.2,
          ),
          boxShadow: notif.isRead
              ? null
              : [
                  BoxShadow(
                    color: notif.accentColor.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading Icon Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: notif.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: notif.accentColor.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Icon(notif.icon, color: notif.accentColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          notif.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w700,
                            color: notif.isRead ? LuminaColors.textSecondary : LuminaColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notif.time,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: LuminaColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      height: 1.4,
                      color: notif.isRead ? LuminaColors.textMuted : LuminaColors.textSecondary,
                    ),
                  ),
                  if (notif.metricBadge != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: notif.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: notif.accentColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        notif.metricBadge!,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: notif.accentColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideY(begin: 0.08, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: LuminaColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(color: LuminaColors.surfaceBorder),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              color: LuminaColors.textMuted,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'NO NOTIFICATIONS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: LuminaColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your institutional vault is up to date and secured.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: LuminaColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
