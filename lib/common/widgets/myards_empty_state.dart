import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/util/myards_theme_tokens.dart';

class MyardsEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double? imageHeight;

  const MyardsEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.imageHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: imageHeight,
              color: MyardsColors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: MyardsSpacing.xl),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: MyardsColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MyardsSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MyardsSpacing.lg),
              child: Text(
                message,
                style: TextStyle(fontSize: 14, color: MyardsColors.textSoft),
                textAlign: TextAlign.center,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: MyardsSpacing.xl),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyardsColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MyardsRadius.md),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: MyardsSpacing.xl,
                    vertical: MyardsSpacing.md,
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
