import 'package:campus_notes_app/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:campus_notes_app/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final IconData? sideIcon;
  final String text;
  final String? subtitle;
  final VoidCallback? onSideIconTap;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool usePremiumBackIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? elevation;
  final Widget? trailing;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    this.sideIcon,
    required this.text,
    this.subtitle,
    this.onSideIconTap,
    this.showBackButton = true,
    this.onBackPressed,
    this.usePremiumBackIcon = true,
    this.backgroundColor,
    this.textColor,
    this.elevation = 0,
    this.trailing,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    const containerHeight = kToolbarHeight;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Determine colors based on theme - use scaffold background for consistency
    final effectiveBackgroundColor = backgroundColor ?? 
        (isDark ? AppColors.backgroundDark : AppColors.backgroundLight);
    final effectiveTextColor = textColor ?? 
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: elevation!,
                  offset: Offset(0, elevation! / 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            height: containerHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                if (showBackButton)
                  GestureDetector(
                    onTap: onBackPressed ?? () => _handleBackPress(context),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: usePremiumBackIcon
                          ? BoxDecoration(
                              color: isDark 
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            )
                          : null,
                      child: Icon(
                        usePremiumBackIcon 
                            ? Icons.arrow_back_ios_new
                            : Icons.chevron_left,
                        size: isTablet ? 24 : 20,
                        color: usePremiumBackIcon 
                            ? AppColors.primary
                            : effectiveTextColor,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 40),

                // Title section
                Expanded(
                  child: centerTitle
                      ? Center(child: _buildTitleSection(context, effectiveTextColor, isTablet, containerHeight))
                      : _buildTitleSection(context, effectiveTextColor, isTablet, containerHeight),
                ),

                // Side icon or trailing widget
                SizedBox(
                  width: 40,
                  child: trailing ??
                      (sideIcon != null
                          ? GestureDetector(
                              onTap: onSideIconTap,
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: isDark 
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : AppColors.primary.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  sideIcon,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : const SizedBox()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, Color textColor, bool isTablet, double containerHeight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              subtitle!,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.6),
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  void _handleBackPress(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    
    // Special navigation logic for specific routes
    if (currentRoute == AppRoutes.userProfile) {
      Navigator.of(context).popUntil((route) {
        return route.settings.name == AppRoutes.profile || route.isFirst;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}