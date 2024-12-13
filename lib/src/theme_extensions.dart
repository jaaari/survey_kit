import 'package:flutter/material.dart' hide Colors;
import 'package:flutter/widgets.dart';
import 'dart:math' as math;
import 'package:survey_kit/src/kuluko_0.2_theme.dart' show FigmaTheme, ColorsTypes;
import 'package:survey_kit/src/kuluko_0.2_theme.dart' as theme;
import 'package:flutter_markdown/flutter_markdown.dart';
extension ThemeExtension on BuildContext {
  // Colors
  theme.IColor get primaryPurple => theme.Colors.primaryPurple;
  theme.IColor get secondaryPurple => theme.Colors.secondaryPurple;
  theme.IColor get background => theme.Colors.background;
  theme.IColor get card => theme.Colors.card;
  theme.IColor get border => theme.Colors.border;
  theme.IColor get textPrimary => theme.Colors.textPrimary;
  theme.IColor get textSecondary => theme.Colors.textSecondary;
  theme.IColor get accentBlue => theme.Colors.accentBlue;
  theme.IColor get accentGreen => theme.Colors.accentGreen;
  theme.IColor get primaryPurple50 => theme.Colors.primaryPurple50;
  theme.IColor get primaryPurple25 => theme.Colors.primaryPurple25;
  theme.IColor get surface => theme.Colors.surface;
  theme.IColor get surfaceBackground => theme.Colors.surfaceBackground;
  theme.IColor get card80 => theme.Colors.card80;

  // Text Styles
  theme.Style get h1 => theme.Styles.h1(this);
  theme.Style get h2 => theme.Styles.h2(this);
  theme.Style get h3 => theme.Styles.h3(this);
  theme.Style get body => theme.Styles.body(this);
  theme.Style get caption => theme.Styles.caption(this);

  // Shadows
  List<theme.Shadow> get shadowUp => 
      FigmaTheme.colorstypes == ColorsTypes.dark ? theme.Shadows.darkShadowUp : theme.Shadows.lightShadowUp;
  List<theme.Shadow> get shadow => 
      FigmaTheme.colorstypes == ColorsTypes.dark ? theme.Shadows.darkShadow : theme.Shadows.lightShadow;

  // Gradients
  LinearGradient get buttonGradient => theme.ColorStyle.buttonGradient;
  LinearGradient get cardGradient => theme.ColorStyle.cardGradient;

  // Theme toggle
  void toggleTheme() {
    print('Toggling theme');
    final currentType = FigmaTheme.colorstypes;
    if (currentType == ColorsTypes.dark) {
      FigmaTheme.modifyColors(ColorsTypes.light);
    } else {
      FigmaTheme.modifyColors(ColorsTypes.dark);
    }
  }

  // Numbers
  theme.INumber get extraSmall => theme.Numbers(this).extraSmall;
  theme.INumber get small => theme.Numbers(this).small;
  theme.INumber get standard => theme.Numbers(this).standard;
  theme.INumber get extraLarge => theme.Numbers(this).extraLarge;
  theme.INumber get doubleExtraLarge => theme.Numbers(this).doubleExtraLarge;
  theme.INumber get tripleExtraLarge => theme.Numbers(this).tripleExtraLarge;
  theme.INumber get medium => theme.Numbers(this).medium;

  // Book card dimensions
  Size get bookCardLarge {
    final screenHeight = MediaQuery.sizeOf(this).height;
    final baseHeight = 800.0; // Design width
    final scale = screenHeight / baseHeight;
    
    // Calculate size while maintaining aspect ratio
    final size = 172.0 * scale;
    
    return Size.square(size);
  }

  Size get bookCardSmall {
    final screenHeight = MediaQuery.sizeOf(this).height;
    final baseHeight = 800.0; // Design width
    final scale = screenHeight / baseHeight;
    
    // Calculate size while maintaining aspect ratio
    final size = 148.0 * scale;
    
    return Size.square(size);
  }

  // Screen dimensions
  double get screenWidth {
    final mediaQuery = MediaQuery.of(this);
    return mediaQuery.size.width;
  }

  double get screenHeight {
    final mediaQuery = MediaQuery.of(this);
    final fullHeight = mediaQuery.size.height;
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;
    return fullHeight - topPadding - bottomPadding;
  }

  double get fullScreenHeight {
    return MediaQuery.of(this).size.height;
  }

  // Screen padding
  double get topPadding => MediaQuery.of(this).padding.top;
  double get bottomPadding => MediaQuery.of(this).padding.bottom;

  // Add markdown style getter
  MarkdownStyleSheet get markdownStyle => MarkdownStyleSheet(
    h1: h1.copyWith(color: textSecondary ),
    h2: h2.copyWith(color: textSecondary),
    h3: h3.copyWith(color: textSecondary),
    p: body.copyWith(color: textSecondary),
    a: body.copyWith(
      color: primaryPurple,
      
    ),
    blockquote: body.copyWith(
      color: textSecondary,
      
    ),
    code: caption.copyWith(
      color: textPrimary,
      backgroundColor: surface,
      fontFamily: 'mono',
    ),
    codeblockPadding: EdgeInsets.all(standard.value),
    blockquotePadding: EdgeInsets.all(standard.value),
    blockquoteDecoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(8),
    ),
    codeblockDecoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
