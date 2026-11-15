import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionTap;
  /// When true, renders a larger editorial display-weight title.
  final bool isLarge;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: isLarge ? 10.0 : 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: isLarge
                      ? theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.charcoal,
                          height: 1.1,
                        )
                      : theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.charcoal,
                        ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: isLarge ? 4 : 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.mutedBrown,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionText != null && onActionTap != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.coral,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
