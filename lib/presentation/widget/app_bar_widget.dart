import 'package:flutter/material.dart';

class EduLearnAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final List<Widget>? actions;

  const EduLearnAppBar({
    super.key,
    this.showBack = false,
    this.actions,
  });

  static double _toolbarHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 700 ? 78 : kToolbarHeight;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;
    final bool isTablet = MediaQuery.of(context).size.width >= 700;

    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      toolbarHeight: isTablet ? 78 : kToolbarHeight,

      leading: showBack
          ? Padding(
        padding: EdgeInsets.all(isTablet ? 14 : 10),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colorScheme.primary,
              size: isTablet ? 20 : 16,
            ),
          ),
        ),
      )
          : null,

      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "Edu",
              style: (isTablet ? textTheme.headlineSmall : textTheme.titleLarge)
                  ?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            TextSpan(
              text: "Learn",
              style: (isTablet ? textTheme.headlineSmall : textTheme.titleLarge)
                  ?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),

      actions: actions != null
          ? actions!
          .map(
            (widget) => Padding(
          padding: EdgeInsets.only(right: isTablet ? 10 : 4),
          child: widget,
        ),
      )
          .toList()
          : null,
    );
  }


  @override
  Size get preferredSize => const Size.fromHeight(78);
}