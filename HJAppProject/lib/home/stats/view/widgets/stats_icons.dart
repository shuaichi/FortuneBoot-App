import 'package:flutter/material.dart';

/// Centralized icon definitions for the Stats/Dashboard module.
/// Follows strict design guidelines:
/// - Rounded style (Material Symbols Rounded preferred)
/// - Semantic clarity
class StatsIcons {
  // --- Summary Card Icons ---
  // Income: Money coming IN (Arrow pointing down/in or Trending Up if growth)
  // Let's use simple semantic arrows for transaction direction in summaries.
  static const IconData income = Icons.arrow_circle_down_rounded; 
  static const IconData expense = Icons.arrow_circle_up_rounded;
  static const IconData balance = Icons.account_balance_wallet_rounded; // Wallet represents current holdings

  // --- Trends ---
  // Positive/Negative trends (Growth vs Decline)
  static const IconData trendUp = Icons.trending_up_rounded;
  static const IconData trendDown = Icons.trending_down_rounded;
  static const IconData trendFlat = Icons.trending_flat_rounded;

  // --- Categories ---
  static const IconData categoryDefault = Icons.category_rounded;
  static const IconData list = Icons.list_rounded;

  // --- Filters / Navigation ---
  static const IconData calendar = Icons.calendar_month_rounded; // Time range
  static const IconData filter = Icons.filter_list_rounded;      // General filter
  static const IconData sort = Icons.sort_rounded;

  // --- Charts ---
  static const IconData chartLine = Icons.show_chart_rounded;
  static const IconData chartPie = Icons.pie_chart_rounded;
  static const IconData chartBar = Icons.bar_chart_rounded;

  // --- Empty States ---
  static const IconData emptyData = Icons.insert_chart_outlined_rounded;
}

/// A standardized icon widget for dashboard consistency.
/// Supports filled background style for category icons.
class DashboardIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final Color? backgroundColor;
  final bool isFilled; // If true, uses background color logic

  const DashboardIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 24.0,
    this.backgroundColor,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.iconTheme.color;
    
    if (isFilled || backgroundColor != null) {
      return Container(
        padding: EdgeInsets.all(size * 0.25),
        decoration: BoxDecoration(
          color: backgroundColor ?? iconColor?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: size,
        ),
      );
    }

    return Icon(
      icon,
      color: iconColor,
      size: size,
    );
  }
}