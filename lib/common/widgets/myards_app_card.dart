import 'package:flutter/material.dart';
import 'package:sixam_mart_delivery/util/myards_theme_tokens.dart';

class MyardsAppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;
  final double? borderRadius;

  const MyardsAppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin ?? const EdgeInsets.only(bottom: MyardsSpacing.md),
      padding: padding ?? const EdgeInsets.all(MyardsSpacing.lg),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(borderRadius ?? MyardsRadius.lg),
        boxShadow: MyardsShadows.soft,
      ),
      child: child,
    );

    if (onTap == null) return card;

    return InkWell(
      borderRadius: BorderRadius.circular(borderRadius ?? MyardsRadius.lg),
      onTap: onTap,
      child: card,
    );
  }
}
