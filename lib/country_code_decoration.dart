import 'package:flutter/widgets.dart';

class CountryCodeDecoration {
  final TextStyle? countryNameTextStyle;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;
  final Widget? suffixIcon;
  final bool showFlag;
  final String labelText;
  final TextStyle? labelStyle;
  CountryCodeDecoration({
    this.backgroundColor,
    this.countryNameTextStyle,
    this.borderRadius,
    this.borderSide,
    this.suffixIcon,
    this.showFlag = true,
    this.labelText = 'Country',
    this.labelStyle,
  });
}
