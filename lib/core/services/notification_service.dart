import 'package:flutter/material.dart';
import '../../theme/lumina_theme.dart';

enum NotificationCategory {
  all,
  yields,
  transfers,
  security,
}

class VaultNotification {
  final String id;
  final String title;
  final String description;
  final String time;
  final NotificationCategory category;
  final IconData icon;
  final Color accentColor;
  final String? metricBadge;
  bool isRead;

  VaultNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.category,
    required this.icon,
    required this.accentColor,
    this.metricBadge,
    this.isRead = false,
  });

  VaultNotification copyWith({
    String? id,
    String? title,
    String? description,
    String? time,
    NotificationCategory? category,
    IconData? icon,
    Color? accentColor,
    String? metricBadge,
    bool? isRead,
  }) {
    return VaultNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      accentColor: accentColor ?? this.accentColor,
      metricBadge: metricBadge ?? this.metricBadge,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Central Reactive Notification Store
/// Synchronizes notification states and real-time unread badges across all screens.
class NotificationService extends ChangeNotifier {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._internal();

  NotificationService._internal() {
    _initDefaultNotifications();
  }

  // Allow custom instances for testing
  factory NotificationService({List<VaultNotification>? initialNotifications}) {
    final service = NotificationService._internal();
    if (initialNotifications != null) {
      service._notifications = List.from(initialNotifications);
    }
    return service;
  }

  late List<VaultNotification> _notifications;

  List<VaultNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  bool get hasUnread => unreadCount > 0;

  void _initDefaultNotifications() {
    _notifications = [
      VaultNotification(
        id: 'notif-1',
        title: 'Arbitrum L2 Yield Compounded',
        description: '+\$348.60 credited to wstETH Staking Vault. Automated hourly yield compounding completed.',
        time: '12m ago',
        category: NotificationCategory.yields,
        icon: Icons.bolt_rounded,
        accentColor: LuminaColors.acidLime,
        metricBadge: '+4.8% APY',
        isRead: false,
      ),
      VaultNotification(
        id: 'notif-2',
        title: 'Biometric Shield Active',
        description: 'Secure Enclave cryptographic check passed with zero anomalies. Biometric signature signed.',
        time: '45m ago',
        category: NotificationCategory.security,
        icon: Icons.fingerprint_rounded,
        accentColor: LuminaColors.electricCobalt,
        metricBadge: 'ENCLAVE OK',
        isRead: false,
      ),
      VaultNotification(
        id: 'notif-3',
        title: 'Instant Wire Settlement',
        description: '+\$12,500.00 received from Sovereign Treasury Liquidity Pool via zero-fee Arbitrum rail.',
        time: '2h ago',
        category: NotificationCategory.transfers,
        icon: Icons.south_west_rounded,
        accentColor: LuminaColors.acidLime,
        metricBadge: 'ZERO FEE',
        isRead: false,
      ),
      VaultNotification(
        id: 'notif-4',
        title: 'Discrete Privacy Shield Engaged',
        description: 'Dynamic camouflage veil activated via phone motion gesture. Balances safely masked.',
        time: '5h ago',
        category: NotificationCategory.security,
        icon: Icons.shield_rounded,
        accentColor: const Color(0xFF6366F1),
        metricBadge: 'VEIL ON',
        isRead: false,
      ),
      VaultNotification(
        id: 'notif-5',
        title: 'LBMA Gold Vault Custody Verified',
        description: 'Proof-of-reserves audited for 2.45 oz Tokenized Gold (PAXG) allocated in Zurich vault.',
        time: '1d ago',
        category: NotificationCategory.yields,
        icon: Icons.diamond_outlined,
        accentColor: LuminaColors.amberWarning,
        metricBadge: 'AUDITED',
        isRead: true,
      ),
    ];
  }

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (final n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  void removeNotification(String id) {
    final countBefore = _notifications.length;
    _notifications.removeWhere((n) => n.id == id);
    if (_notifications.length != countBefore) {
      notifyListeners();
    }
  }

  void addNotification(VaultNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void resetToDefaults() {
    _initDefaultNotifications();
    notifyListeners();
  }
}
