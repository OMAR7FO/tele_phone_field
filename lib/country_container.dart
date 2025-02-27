import "package:custom_phone_field/countries.dart";
import "package:custom_phone_field/country_code_decoration.dart";
import 'package:flutter/material.dart';

class CountryContainer extends StatelessWidget {
  const CountryContainer({
    super.key,
    required this.height,
    this.selectedCountry,
    this.decoration,
    this.width,
    this.onTap,
    this.languageCode = 'en',
  });
  final CountryPhone? selectedCountry;
  final CountryCodeDecoration? decoration;
  final double height;
  final double? width;
  final VoidCallback? onTap;
  final String languageCode;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: height,
        width: width,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: <Widget>[
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: (height - 60 != 0)
                        ? EdgeInsets.symmetric(
                            vertical: height,
                            horizontal: 12,
                          )
                        : null,
                    enabled: false,
                    disabledBorder: OutlineInputBorder(
                      borderRadius:
                          decoration?.borderRadius ?? BorderRadius.circular(0),
                      borderSide: decoration?.borderSide ?? BorderSide.none,
                    ),
                    fillColor: decoration?.backgroundColor,
                    filled: true,
                    suffixIcon: decoration?.suffixIcon,
                    labelStyle: decoration?.labelStyle,
                    labelText: decoration?.labelText,
                    floatingLabelBehavior: selectedCountry != null
                        ? FloatingLabelBehavior.always
                        : FloatingLabelBehavior.never,
                  ),
                ),
                AnimatedAlign(
                  alignment: selectedCountry != null
                      ? AlignmentDirectional.centerStart
                      : AlignmentDirectional.bottomStart,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: selectedCountry != null
                        ? RichText(
                            text: TextSpan(
                              children: [
                                if (decoration?.showFlag ?? true)
                                  TextSpan(
                                    text: "${selectedCountry!.flag} ",
                                    style: TextStyle(
                                      fontSize: decoration
                                          ?.countryNameTextStyle?.fontSize,
                                    ),
                                  ),
                                TextSpan(
                                  text: selectedCountry!.localizedName(
                                    languageCode,
                                  ),
                                  style: decoration?.countryNameTextStyle,
                                ),
                              ],
                            ),
                          )
                        : SizedBox(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
