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
    semanticLabel,
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
      case Icons.refresh:
      case Icons.refresh_rounded:
        return '🔄';
      case Icons.add:
      case Icons.add_circle_outline:
      case Icons.add_circle_outline_rounded:
        return '➕';
      case Icons.list_alt_rounded:
        return '📋';
      case Icons.format_list_numbered_rounded:
        return '🔢';
      case Icons.inventory_2:
      case Icons.inventory_2_rounded:
      case Icons.inventory_2_outlined:
        return '👜';
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
      case Icons.schedule:
      case Icons.schedule_rounded:
        return '🕖';
      case Icons.search:
        return '🔎';
      case Icons.chevron_right:
        return '👉';
      case Icons.edit:
      case Icons.edit_rounded:
        return '🖊️';
      case Icons.delete:
      case Icons.delete_forever:
      case Icons.delete_outline_rounded:
        return '🗑️';
      case Icons.account_balance:
      case Icons.account_balance_rounded:
        return '🏦';
      case Icons.receipt:
      case Icons.receipt_long_rounded:
        return '🧾';
      case Icons.currency_exchange:
        return '💱';
      case Icons.work_outline:
        return '💼';
      case Icons.checkroom:
        return '👕';
      case Icons.grid_view:
        return '📐';
      case Icons.numbers:
        return '🔢';
      case Icons.category:
        return '🗂️';
      case Icons.notes:
        return '📝';
      case Icons.save:
      case Icons.save_rounded:
        return '💾';
      case Icons.person:
        return '👤';
      case Icons.phone:
        return '📱';
      case Icons.business:
        return '🏢';
      case Icons.precision_manufacturing:
        return '⚙️';
      case Icons.palette:
        return '🎨';
      case Icons.image:
        return '🖼️';
      default:
        return '❔';
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
