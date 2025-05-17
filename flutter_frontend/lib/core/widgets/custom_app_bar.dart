import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/theme/app_theme.dart';

/// A custom consistent AppBar widget for the Workshop Assistant app.
/// 
/// This widget creates a standardized AppBar with consistent styling across the app,
/// while allowing customization of title, actions, etc.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title text to display in the AppBar
  final String title;
  
  /// Style for the title text (defaults to bold, size 20)
  final TextStyle? titleStyle;
  
  /// Custom title widget (overrides the title text if provided)
  final Widget? titleWidget;
  
  /// Optional leading widget
  final Widget? leading;
  
  /// Action widgets to display on the right side
  final List<Widget>? actions;
  
  /// Whether to center the title
  final bool centerTitle;
  
  /// Background color of the AppBar (overrides feature color)
  final Color? backgroundColor;
  
  /// Foreground/text/icon color
  final Color? foregroundColor;
  
  /// The elevation of the AppBar
  final double elevation;
  
  /// Whether to show the bottom rounded corners
  final bool roundedBottom;
  
  /// Radius of the bottom corners if rounded
  final double bottomRadius;
  
  /// Feature identifier for color theming ('home', 'clients', 'vehicles', etc.)
  /// This will be used to determine the background color if backgroundColor is not provided
  final String feature;

  const CustomAppBar({
    super.key,
    required this.title,
    this.titleStyle,
    this.titleWidget,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 3.0,
    this.roundedBottom = true,
    this.bottomRadius = 16.0,
    this.feature = 'home',
  });
  @override
  Widget build(BuildContext context) {
    // Use app theme's default styles unless overridden
    final featureColor = AppTheme.getFeatureColor(feature);
    final bgColor = backgroundColor ?? featureColor;
    final fgColor = foregroundColor ?? AppTheme.textPrimaryColor;
    
    return AppBar(
      title: titleWidget ?? Text(
        title,
        style: titleStyle ?? AppTheme.appBarTitleStyle,
      ),
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: elevation,
      shape: roundedBottom ? RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(bottomRadius),
        ),
      ) : null,
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
