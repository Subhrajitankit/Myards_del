import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/util/myards_theme_tokens.dart';

class MyardsStatusChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? borderRadius;

  const MyardsStatusChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MyardsSpacing.md,
        vertical: MyardsSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? MyardsColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(borderRadius ?? MyardsRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor ?? MyardsColors.primary),
            const SizedBox(width: MyardsSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor ?? MyardsColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
