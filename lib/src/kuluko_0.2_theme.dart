// ignore_for_file: overridden_fields, unused_element, non_constant_identifier_names

/// The all getter and classes with variables and functions statics: 
/// [Styles], [Shadows], [ColorStyle], [FigmaTheme], [Numbers], [Colors]
///
///
/// Text Style Documents:
/// * [TextStyle] are represented in an class called [Style].
/// * To access all [Style] statically, you can just access them using the [Styles] class.
/// * To color a [Style], just use the .tint([IColor]) function.
/// * [Style] may or may not have figma variables depending on the design in figma
/// * The attributes exported from figma are [fontFamily], [fontSize], [decoration], [fontStyle], [fontWeight], [height], [letterSpacing]
/// 
/// Shadow Documents:
/// * ONLY support DROP_SHADOW and INNER_SHADOW.
/// * [BoxShadow] are represented in an class called [Shadow].
/// * To access all [Shadow] statically, you can just access them using the [Shadows}] class.
/// * Shadows may or may not have figma variables depending on the design in figma
/// * The attributes exported from figma are [color], [offset], [blurRadius], [spreadRadius], [blurStyle]
/// 
/// Color Styles Documents:
/// * Support SOLID COLOR and GRADIENT LINEAR and GRADIENT RADIAL.
/// * To access all [IColor] statically, you can just access them using the [ColorStyle}] class.
/// * Colors may or may not have figma variables depending on the design in figma
/// 
/// *IMPORTANT*: You need a [FigmaTheme] on top of your Material so that colors, sizes, strings, booleans are rebuilt when changed.
///
/// ```dart
///  class MyApp extends StatelessWidget {
///    const MyApp({super.key});
///
///    @override
///    Widget build(BuildContext context) {
///      return const FigmaTheme(
///        child: MaterialApp(
///          title: 'Figma Demo',
///          home: MyHomePage(title: 'Figma Demo Home Page'),
///        ),
///      );
///    }
///  }
/// ```
///
///
/// The variable [Numbers] is a getter that fetches the style[NumbersDefault] based on the set `MODE`[NumbersTypes]
/// To change the MODE of [Numbers] just use the function [FigmaTheme.NumbersDefault] passing the enum [NumbersTypes]
///
/// [NumbersDefault] is a sealed class that contains all the variables of the collection Numbers
/// [_NumbersMode1] is a class that contains all the variables of the collection Numbers in the mode Mode 1
///
///
/// The variable [Colors] is a getter that fetches the style[ColorsDefault] based on the set `MODE`[ColorsTypes]
/// To change the MODE of [Colors] just use the function [FigmaTheme.ColorsDefault] passing the enum [ColorsTypes]
///
/// [ColorsDefault] is a sealed class that contains all the variables of the collection Colors
/// [_ColorsDark] is a class that contains all the variables of the collection Colors in the mode Dark
///
///
library figma_theme;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survey_kit/src/theme_extensions.dart';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';

    AnimationController? _animationControllerNumbersDefault;
AnimationController? _animationControllerColorsDefault;
    class FigmaTheme extends StatefulWidget {
        final Widget child;
        final Duration duration;
        const FigmaTheme({
          super.key,
          required this.child,
          this.duration = const Duration(milliseconds: 300),
        });
  
static NumbersTypes numberstypes = NumbersTypes.mode1;
static void modifyNumbers(BuildContext context, NumbersTypes type) {
   numberstypes = type;
   _NumbersLast = _Numbers.value;
   switch (type) {
     case NumbersTypes.mode1:
       _Numbers.value = _NumbersMode1.withContext(context);
   }
}
static ColorsTypes colorstypes = ColorsTypes.dark;
static Future<void> modifyColors(ColorsTypes type) async {
    colorstypes = type;
    _ColorsLast = _Colors.value;
    switch (type) {
      case ColorsTypes.dark:
        _Colors.value = _ColorsDark._();
        break;
      case ColorsTypes.light:
        _Colors.value = _ColorsLight._();
        break;
    }
    // Save theme preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themePreferenceKey, type.toString());
  }
@override
      State<FigmaTheme> createState() => _FigmaThemeState();
    }
class _FigmaThemeState extends State<FigmaTheme>  with TickerProviderStateMixin{
  
  void _rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }
 @override
      void initState() {
        super.initState();
         _animationControllerNumbersDefault = AnimationController(
          vsync: this,
          duration: widget.duration,
        );
 _animationControllerColorsDefault = AnimationController(
          vsync: this,
          duration: widget.duration,
        );
_Numbers.addListener((){
   _animationControllerNumbersDefault?.forward(from: 0);
});
_Colors.addListener((){
   _animationControllerColorsDefault?.forward(from: 0);
});

  }
    
    @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _animationControllerNumbersDefault,
_animationControllerColorsDefault,
      ]),
      builder: (context, _) {
        _rebuildAllChildren(context);
        return widget.child;
      },
    );
  }
}
ValueNotifier<NumbersDefault> _Numbers = ValueNotifier(_NumbersMode1._());
NumbersDefault _NumbersLast = _NumbersMode1._();
enum NumbersTypes {mode1}
NumbersDefault Numbers(BuildContext context) {
  if (_animationControllerNumbersDefault?.isAnimating ?? false) {
    return NumbersDefault._lerpResolve(
      _Numbers.value, 
      _NumbersLast, 
      _animationControllerNumbersDefault?.value ?? 1,
    );
  }
  return _Numbers.value;
}

ValueNotifier<ColorsDefault> _Colors = ValueNotifier(_ColorsDark._());
ColorsDefault _ColorsLast = _ColorsDark._();
enum ColorsTypes {dark, light}
ColorsDefault get Colors {
      // TODO: You need to change this method if you want to change the behavior.
        if( _animationControllerColorsDefault?.isAnimating??false){
         return ColorsDefault._lerpResolve(_Colors.value, _ColorsLast, _animationControllerColorsDefault?.value??1,);
       }
         return _Colors.value;
      }

 class NumbersDefault {
  NumbersDefault._();
  
  INumber? _extraSmall;
  INumber? _small;
  INumber? _standard;
  INumber? _extraLarge;
  INumber? _doubleExtraLarge;
  INumber? _tripleExtraLarge;
  INumber? _medium;

  // Getters with null safety
  INumber get extraSmall => _extraSmall ?? const INumber._(2);
  INumber get small => _small ?? const INumber._(4);
  INumber get standard => _standard ?? const INumber._(8);
  INumber get extraLarge => _extraLarge ?? const INumber._(16);
  INumber get doubleExtraLarge => _doubleExtraLarge ?? const INumber._(24);
  INumber get tripleExtraLarge => _tripleExtraLarge ?? const INumber._(32);
  INumber get medium => _medium ?? const INumber._(12);

  // Setters
  set extraSmall(INumber value) => _extraSmall = value;
  set small(INumber value) => _small = value;
  set standard(INumber value) => _standard = value;
  set extraLarge(INumber value) => _extraLarge = value;
  set doubleExtraLarge(INumber value) => _doubleExtraLarge = value;
  set tripleExtraLarge(INumber value) => _tripleExtraLarge = value;
  set medium(INumber value) => _medium = value;

    NumbersDefault._lerp({
    required INumber extraSmall,
    required INumber small,
    required INumber standard,
    required INumber extraLarge,
    required INumber doubleExtraLarge,
    required INumber tripleExtraLarge,
    required INumber medium,
  }) {
    _extraSmall = extraSmall;
    _small = small;
    _standard = standard;
    _extraLarge = extraLarge;
    _doubleExtraLarge = doubleExtraLarge;
    _tripleExtraLarge = tripleExtraLarge;
    _medium = medium;
  }

  static NumbersDefault _lerpResolve(NumbersDefault a, NumbersDefault b, double t) {
    return NumbersDefault._lerp(
      extraSmall: INumber._(b.extraSmall.value._lerp(a.extraSmall.value, t)),
      small: INumber._(b.small.value._lerp(a.small.value, t)),
      standard: INumber._(b.standard.value._lerp(a.standard.value, t)),
      extraLarge: INumber._(b.extraLarge.value._lerp(a.extraLarge.value, t)),
      doubleExtraLarge: INumber._(b.doubleExtraLarge.value._lerp(a.doubleExtraLarge.value, t)),
      tripleExtraLarge: INumber._(b.tripleExtraLarge.value._lerp(a.tripleExtraLarge.value, t)),
      medium: INumber._(b.medium.value._lerp(a.medium.value, t)),
    );
  }
}

class _NumbersMode1 extends NumbersDefault {
  _NumbersMode1._() : super._();

  factory _NumbersMode1.withContext(BuildContext context) {
    final instance = _NumbersMode1._();
    instance._initializeResponsive(context);
    return instance;
  }

  void _initializeResponsive(BuildContext context) {
    extraSmall = INumber._(ResponsiveValue.value(context, 2));
    small = INumber._(ResponsiveValue.value(context, 4));
    standard = INumber._(ResponsiveValue.value(context, 8));
    extraLarge = INumber._(ResponsiveValue.value(context, 16));
    doubleExtraLarge = INumber._(ResponsiveValue.value(context, 24));
    tripleExtraLarge = INumber._(ResponsiveValue.value(context, 32));
    medium = INumber._(ResponsiveValue.value(context, 12));
  }
}

 class ColorsDefault{
ColorsDefault._();
ColorsDefault._lerp({
  required this.primaryPurple,
  required this.secondaryPurple,
  required this.background,
  required this.card,
  required this.border,
  required this.textPrimary,
  required this.textSecondary,
  required this.accentBlue,
  required this.accentGreen,
  required this.primaryPurple50,
  required this.primaryPurple25,
  required this.surface,
  required this.surfaceBackground,
  required this.card80,
});
  late final IColor primaryPurple;
  late final IColor secondaryPurple;
  late final IColor background;
  late final IColor card;
  late final IColor border;
  late final IColor textPrimary;
  late final IColor textSecondary;
  late final IColor accentBlue;
  late final IColor accentGreen;
  late final IColor primaryPurple50;
  late final IColor primaryPurple25;
  late final IColor surface;
  late final IColor surfaceBackground;
  late final IColor card80;

  static ColorsDefault _lerpResolve(ColorsDefault a, ColorsDefault b, double t) {
    return ColorsDefault._lerp(
      primaryPurple: IColor._(b.primaryPurple._lerp(a.primaryPurple, t).value),
      secondaryPurple: IColor._(b.secondaryPurple._lerp(a.secondaryPurple, t).value),
      background: IColor._(b.background._lerp(a.background, t).value),
      card: IColor._(b.card._lerp(a.card, t).value),
      border: IColor._(b.border._lerp(a.border, t).value),
      textPrimary: IColor._(b.textPrimary._lerp(a.textPrimary, t).value),
      textSecondary: IColor._(b.textSecondary._lerp(a.textSecondary, t).value),
      accentBlue: IColor._(b.accentBlue._lerp(a.accentBlue, t).value),
      accentGreen: IColor._(b.accentGreen._lerp(a.accentGreen, t).value),
      primaryPurple50: IColor._(b.primaryPurple50._lerp(a.primaryPurple50, t).value),
      primaryPurple25: IColor._(b.primaryPurple25._lerp(a.primaryPurple25, t).value),
      surface: IColor._(b.surface._lerp(a.surface, t).value),
      surfaceBackground: IColor._(b.surfaceBackground._lerp(a.surfaceBackground, t).value),
      card80: IColor._(b.card80._lerp(a.card80, t).value),
    );
  }
}

class _ColorsDark extends ColorsDefault {
_ColorsDark._() : super._();
@override
IColor get primaryPurple => const IColor._fromARGB(255, 211, 188, 253);
@override
IColor get secondaryPurple => const IColor._fromARGB(255, 161, 82, 235);
@override
IColor get background => const IColor._fromARGB(255, 28, 28, 28);
@override
IColor get card => const IColor._fromARGB(255, 37, 37, 37);
@override
IColor get border => const IColor._fromARGB(255, 51, 51, 51);
@override
IColor get textPrimary => const IColor._fromARGB(255, 255, 255, 255);
@override
IColor get textSecondary => const IColor._fromARGB(255, 187, 187, 187);
@override
IColor get accentBlue => const IColor._fromARGB(255, 74, 144, 226);
@override
IColor get accentGreen => const IColor._fromARGB(255, 108, 196, 124);
@override
IColor get primaryPurple50 => const IColor._fromARGB(128, 179, 156, 208);
@override
IColor get primaryPurple25 => const IColor._fromARGB(64, 179, 156, 208);
@override
IColor get surface => const IColor._fromARGB(255, 30, 30, 30);
@override
IColor get surfaceBackground => const IColor._fromARGB(255, 30, 30, 30);
@override
IColor get card80 => const IColor._fromARGB(204, 37, 37, 37);
}

class _ColorsLight extends ColorsDefault {
  _ColorsLight._() : super._();
  
  @override
  IColor get primaryPurple => const IColor._fromARGB(255, 107, 91, 149);
  @override
  IColor get secondaryPurple => const IColor._fromARGB(255, 161, 82, 235);
  @override
  IColor get background => const IColor._fromARGB(255, 255, 255, 255);
  @override
  IColor get card => const IColor._fromARGB(255, 250, 250, 250);
  @override
  IColor get border => const IColor._fromARGB(255, 238, 238, 238);
  @override
  IColor get textPrimary => const IColor._fromARGB(255, 33, 33, 33);
  @override
  IColor get textSecondary => const IColor._fromARGB(255, 117, 117, 117);
  @override
  IColor get accentBlue => const IColor._fromARGB(255, 166, 200, 255);
  @override
  IColor get accentGreen => const IColor._fromARGB(255, 163, 217, 165);
  @override
  IColor get primaryPurple50 => const IColor._fromARGB(128, 211, 188, 253);
  @override
  IColor get primaryPurple25 => const IColor._fromARGB(64, 211, 188, 253);
  @override
  IColor get surface => const IColor._fromARGB(255, 250, 250, 250);
  @override
  IColor get surfaceBackground => const IColor._fromARGB(255, 255, 255, 255);
  @override
  IColor get card80 => const IColor._fromARGB(204, 250, 250, 250);
}

class ColorStyle {
  ColorStyle._();
  
  static const buttonGradient = LinearGradient(
    transform: GradientRotation(3.141592653589793),
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, 0.5350000262260437],
    colors: [const IColor._fromARGB(255, 202, 70, 251), const IColor._fromARGB(255, 156, 43, 250)],
  );

  static LinearGradient get cardGradient => FigmaTheme.colorstypes == ColorsTypes.dark 
    ? _darkCardGradient 
    : _lightCardGradient;

  static final _darkCardGradient = LinearGradient(
    transform: GradientRotation(3.141592653589793),
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, 1],
    colors: [Colors.card, const IColor._fromARGB(255, 31, 27, 33)],
  );

  static const _lightCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.7250000238418579, 1],
    colors: [const IColor._fromARGB(255, 255, 255, 255), const IColor._fromARGB(255, 224, 208, 249)],
  );
}

class Style extends TextStyle {

    const Style._({
       super.inherit = true,
       super.color,
       super.backgroundColor,
       super.fontSize,
       super.fontWeight,
       super.fontStyle,
       super.letterSpacing,
       super.wordSpacing,
       super.textBaseline,
       super.height,
       super.leadingDistribution,
       super.locale,
       super.foreground,
       super.background,
       super.shadows,
       super.fontFeatures,
       super.fontVariations,
       super.decoration,
       super.decorationColor,
       super.decorationStyle,
       super.decorationThickness,
       super.debugLabel,
       super.fontFamilyFallback,
       super.overflow,
       super.fontFamily,
     });
     
     

   Style tint(IColor? color) =>
       Style._style(copyWith(color: color));

    static FontWeight _parseVariableWeight(double parse) {
      if (parse <= 100) {
        return FontWeight.w100;
      } else if (parse <= 200) {
        return FontWeight.w200;
      } else if (parse <= 300) {
        return FontWeight.w300;
      } else if (parse <= 400) {
        return FontWeight.w400;
      } else if (parse <= 500) {
        return FontWeight.w500;
      } else if (parse <= 600) {
        return FontWeight.w600;
      } else if (parse <= 700) {
        return FontWeight.w700;
      } else if (parse <= 800) {
        return FontWeight.w800;
      } else {
        return FontWeight.w900;
      }
    }

    static FontStyle _parseStringStyle(String parse) {
      return parse.contains("italic") ? FontStyle.italic : FontStyle.normal;
    }

   
   factory Style._style(TextStyle textStyle) {
     return Style._(
       inherit: textStyle.inherit,
       color: textStyle.color,
       backgroundColor: textStyle.backgroundColor,
       fontSize: textStyle.fontSize,
       fontWeight: textStyle.fontWeight,
       fontStyle: textStyle.fontStyle,
       letterSpacing: textStyle.letterSpacing,
       wordSpacing: textStyle.wordSpacing,
       textBaseline: textStyle.textBaseline,
       height: textStyle.height,
       leadingDistribution: textStyle.leadingDistribution,
       locale: textStyle.locale,
       foreground: textStyle.foreground,
       background: textStyle.background,
       shadows: textStyle.shadows,
       fontFeatures: textStyle.fontFeatures,
       fontVariations: textStyle.fontVariations,
       decoration: textStyle.decoration,
       decorationColor: textStyle.decorationColor,
       decorationStyle: textStyle.decorationStyle,
       decorationThickness: textStyle.decorationThickness,
       debugLabel: textStyle.debugLabel,
       fontFamily: textStyle.fontFamily,
       fontFamilyFallback: textStyle.fontFamilyFallback,
       overflow: textStyle.overflow,
     );
   }
  }
 
class Styles {
  const Styles._();

  // Base parent style that all other styles will inherit from
  static const TextStyle _parent = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: 0,
  );

  static TextStyle _buildResponsiveStyle(TextStyle baseStyle, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const baseWidth = 375.0;
    
    final scaleFactor = screenWidth / baseWidth;
    
    final scaledSize = (baseStyle.fontSize! * scaleFactor).clamp(
      baseStyle.fontSize! * 0.8,
      baseStyle.fontSize! * 1.4
    );

    return baseStyle.copyWith(fontSize: scaledSize);
  }

  static Style h1(BuildContext context) => Style._style(
    _buildResponsiveStyle(
      _parent.copyWith(
        fontFamily: "Inter",
        fontSize: 28,
        decoration: TextDecoration.none,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w700,
        height: 1.1999999455043249,
        letterSpacing: 0,
      ),
      context,
    ),
  );

  static Style h2(BuildContext context) => Style._style(
    _buildResponsiveStyle(
      _parent.copyWith(
        fontFamily: "Inter",
        fontSize: 24,
        decoration: TextDecoration.none,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w700,
        height: 1.1999999682108562,
        letterSpacing: 0,
      ),
      context,
    ),
  );

  static Style h3(BuildContext context) => Style._style(
    _buildResponsiveStyle(
      _parent.copyWith(
        fontFamily: "Inter",
        fontSize: 20,
        decoration: TextDecoration.none,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0,
      ),
      context,
    ),
  );

  static Style body(BuildContext context) => Style._style(
    _buildResponsiveStyle(
      _parent.copyWith(
        fontFamily: "Inter",
        fontSize: 16,
        decoration: TextDecoration.none,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
        height: 1.2000000476837158,
        letterSpacing: 0,
      ),
      context,
    ),
  );

  static Style caption(BuildContext context) => Style._style(
    _buildResponsiveStyle(
      _parent.copyWith(
        fontFamily: "Inter",
        fontSize: 12,
        decoration: TextDecoration.none,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
        height: 1.1999999682108562,
        letterSpacing: 0,
      ),
      context,
    ),
  );
}
class Shadow extends BoxShadow {
    const Shadow._({
      super.color,
      super.offset,
      super.blurRadius,
      super.spreadRadius = 0.0,
      super.blurStyle,
    });
  }
class Shadows {
      const Shadows._();
  
static final List<Shadow> lightShadowUp = [
  Shadow._(
color: Color.fromRGBO(0, 0, 0, 0.10000000149011612),
offset: Offset(0, -4),
blurRadius: 8,
spreadRadius: 0,
blurStyle: BlurStyle.normal,
),
];

static final List<Shadow> darkShadowUp = [
  Shadow._(
color: Color.fromRGBO(0, 0, 0, 0.20000000298023224),
offset: Offset(0, -4),
blurRadius: 8,
spreadRadius: 0,
blurStyle: BlurStyle.normal,
),
];

static final List<Shadow> lightShadow = [
  Shadow._(
color: Color.fromRGBO(0, 0, 0, 0.15000000596046448),
offset: Offset(0, 4),
blurRadius: 8,
spreadRadius: 0,
blurStyle: BlurStyle.normal,
),
];

static final List<Shadow> darkShadow = [
  Shadow._(
color: Color.fromRGBO(0, 0, 0, 0.25),
offset: Offset(0, 4),
blurRadius: 8,
spreadRadius: 0,
blurStyle: BlurStyle.normal,
),
];

}


  class IColor extends Color {
    const IColor._(int value) : super(value);
    const IColor._fromARGB(int a, int r, int g, int b)
      : super.fromARGB(a, r, g, b);
  }


  class INumber {
    final double value;
    const INumber._(this.value);
  }


  class IString {
    final String value;
    const IString._(this.value);
  }


  class IBool {
    final bool value;
    const IBool._(this.value);
  }


extension _LerpDouble on double {
  double _lerp(double b, double t) {
    return lerpDouble(this, b, t) ?? this;
  }
}

extension _LerpColor on Color {
  Color _lerp(Color b, double t) {
    return Color.lerp(this, b, t) ?? this;
  }
}

extension _LerpString on String {
  String _lerp(String b, double t) {
    return t < 0.5 ? b : this;
  }
}

extension _LerpBoolean on bool {
  bool _lerp(bool b, double t) {
    return t < 0.5 ? b : this;
  }
}

const String themePreferenceKey = 'selected_theme';

class ThemePreference {
  static final ThemePreference _instance = ThemePreference._internal();
  factory ThemePreference() => _instance;
  ThemePreference._internal();

  Future<void> setTheme(ColorsTypes theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(themePreferenceKey, theme.toString());
  }

  Future<ColorsTypes> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeStr = prefs.getString(themePreferenceKey);
    return themeStr == ColorsTypes.light.toString() 
        ? ColorsTypes.light 
        : ColorsTypes.dark;
  }
}

// Add a method to initialize the theme
Future<void> initializeTheme() async {
  final savedTheme = await ThemePreference().getTheme();
  _Colors.value = savedTheme == ColorsTypes.light 
      ? _ColorsLight._() 
      : _ColorsDark._();
  _ColorsLast = _Colors.value;
}

// Modify your theme switching logic to persist the change
Future<void> setTheme(ColorsTypes type) async {
  await ThemePreference().setTheme(type);
  _Colors.value = type == ColorsTypes.light 
      ? _ColorsLight._() 
      : _ColorsDark._();
  _ColorsLast = _Colors.value;
}

class BaseScreenDimensions {
  static const double width = 360.0;  // Base design width
  static const double height = 800.0;  // Base design height
  
  // Scale factors
  static const double minScale = 0.8;
  static const double maxScale = 1.4;
}

class ResponsiveValue {
  static double scale(BuildContext context) {
    final width = context.screenWidth;
    final height = context.screenHeight;
    
    // Use the smaller scaling factor to ensure UI fits
    final widthScale = width / BaseScreenDimensions.width;
    final heightScale = height / BaseScreenDimensions.height;
    
    return math.min(widthScale, heightScale).clamp(
      BaseScreenDimensions.minScale,
      BaseScreenDimensions.maxScale
    );
  }

 static double value(BuildContext context, double input) {
  final scaleFactor = scale(context);
  print('Screen scale factor: $scaleFactor');
  print('Input value: $input');
  print('Scaled value: ${input * scaleFactor}');
  return input * scale(context);
}
}