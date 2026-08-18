import 'package:flutter/material.dart';

/// Real, platform-rendered colourful emoji icons used as the app's visual icon layer.
/// Material IconData is kept at call sites so behaviour/layout remain unchanged;
/// this widget only changes the rendered artwork.
class Icon extends StatelessWidget {
  final IconData? icon;
  final double? size;
  final Color? color;
  final List<Shadow>? shadows;
  final String? semanticLabel;

  const Icon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.shadows,
    this.semanticLabel,
    double? fill,
    double? weight,
    double? grade,
    double? opticalSize,
    TextDirection? textDirection,
    bool? applyTextScaling,
    BlendMode? blendMode,
    FontWeight? fontWeight,
  });

  static String _emoji(IconData? icon) {
    switch (icon) {
      case Icons.dashboard:
      case Icons.dashboard_rounded:
        return '🖥️';
      case Icons.work:
      case Icons.work_rounded:
      case Icons.work_outline:
        return '💼';
      case Icons.history:
      case Icons.history_rounded:
        return '🗓️';
      case Icons.account_balance_wallet:
      case Icons.account_balance_wallet_rounded:
        return '👜';
      case Icons.settings:
      case Icons.settings_rounded:
        return '🎛️';
      case Icons.refresh_rounded:
        return '🔄';

      case Icons.add_circle_outline:
      case Icons.add:
        return '➕';
      case Icons.list_alt_rounded:
        return '📋';
      case Icons.inventory_2_rounded:
      case Icons.inventory_2:
      case Icons.inventory_2_outlined:
        return '📦';
      case Icons.today_rounded:
        return '📆';
      case Icons.calendar_view_week:
      case Icons.calendar_view_week_rounded:
        return '🗓️';
      case Icons.calendar_month:
      case Icons.calendar_month_rounded:
        return '📆';
      case Icons.payments:
      case Icons.payments_rounded:
        return '💵';
      case Icons.auto_awesome_rounded:
        return '✨';
      case Icons.schedule_rounded:
        return '🕖';

      case Icons.search:
        return '🔎';
      case Icons.chevron_right:
        return '👉';
      case Icons.edit:
        return '🖊️';
      case Icons.delete_forever:
      case Icons.delete:
        return '🗑️';

      case Icons.account_balance:
        return '🏦';
      case Icons.receipt:
        return '🧾';
      case Icons.currency_exchange:
        return '💱';
      case Icons.currency_rupee:
        return '🪙';

      case Icons.checkroom:
        return '👔';
      case Icons.grid_view:
        return '📐';
      case Icons.numbers:
        return '🔢';
      case Icons.category:
        return '🗂️';
      case Icons.notes:
        return '📝';
      case Icons.save:
        return '💾';
      case Icons.calendar_today:
        return '📆';

      case Icons.person:
        return '👤';
      case Icons.phone:
        return '📱';
      case Icons.business:
        return '🏢';
      case Icons.precision_manufacturing:
        return '⚙️';
      case Icons.assignment:
        return '📋';
      case Icons.palette:
        return '🎨';
      case Icons.image:
      case Icons.photo_library:
      case Icons.photo_camera:
        return '🖼️';
      case Icons.notifications:
      case Icons.notifications_none:
        return '🔔';
      case Icons.language:
        return '🌐';
      case Icons.lock:
      case Icons.lock_outline:
        return '🔐';
      case Icons.tune:
        return '🎛️';
      case Icons.build:
        return '🔧';
      case Icons.done:
      case Icons.check:
        return '✅';

      default:
        return '🔹';
    }
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _emoji(icon);
    return Semantics(
      label: semanticLabel,
      image: true,
      child: SizedBox(
        width: (size ?? 24) + 4,
        height: (size ?? 24) + 4,
        child: Center(
          child: Text(
            emoji,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size ?? 24,
              height: 1,
              fontFamilyFallback: const ['Noto Color Emoji'],
              shadows: shadows,
            ),
          ),
        ),
      ),
    );
  }
}
