import 'package:flutter/material.dart';

class CustomToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  const CustomToggle({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 700;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 18 : 14,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(isTablet ? 26 : 22),
        border: Border.all(
          color: value
              ? color.primary.withValues(alpha: 0.35)
              : color.outline.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // ICON BOX
          Container(
            width: isTablet ? 52 : 40,
            height: isTablet ? 52 : 40,
            decoration: BoxDecoration(
              color: value
                  ? color.primary.withValues(alpha: 0.18)
                  : color.onSurface.withValues(alpha: 0.06),
              borderRadius:
              BorderRadius.circular(isTablet ? 16 : 12),
            ),
            child: Icon(
              icon,
              color: value
                  ? color.primary
                  : color.onSurface.withValues(alpha: 0.4),
              size: isTablet ? 26 : 20,
            ),
          ),

          SizedBox(width: isTablet ? 18 : 14),

          // title and subtitle part*
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (isTablet
                      ? text.titleMedium
                      : text.bodyMedium)
                      ?.copyWith(
                    color: color.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: isTablet ? 4 : 2),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: (isTablet
                      ? text.bodyMedium
                      : text.bodySmall)
                      ?.copyWith(
                    color:
                    color.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: isTablet ? 18 : 12),

          // toggle section operations
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: isTablet ? 62 : 50,
              height: isTablet ? 34 : 28,
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(isTablet ? 18 : 14),
                color: value
                    ? color.primary
                    : color.outline.withValues(alpha: 0.3),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: value
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.all(isTablet ? 4 : 3),
                  width: isTablet ? 26 : 22,
                  height: isTablet ? 26 : 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.onPrimary,
                    boxShadow: [
                      BoxShadow(
                        color:
                        color.shadow.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}