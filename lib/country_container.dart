import "package:custom_phone_field/countries.dart";
import "package:custom_phone_field/country_code_decoration.dart";
import "package:flutter/material.dart";

class CountryContainer extends StatelessWidget {
  const CountryContainer({
    super.key,
    required this.height,
    this.selectedCountry,
    this.decoration,
    this.width,
    this.onTap,
  });
  final CountryPhone? selectedCountry;
  final CountryCodeDecoration? decoration;
  final double height;
  final double? width;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: <Widget>[
              GestureDetector(
                onTap: onTap,
                child: TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding:
                        (height - 60 != 0)
                            ? EdgeInsets.symmetric(
                              vertical: height,
                              horizontal: 12,
                            )
                            : EdgeInsets.symmetric(horizontal: 12),
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
                    floatingLabelBehavior:
                        selectedCountry != null
                            ? FloatingLabelBehavior.always
                            : FloatingLabelBehavior.never,
                  ),
                ),
              ),
              AnimatedAlign(
                alignment:
                    selectedCountry != null
                        ? Alignment.centerLeft
                        : Alignment.bottomLeft,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child:
                      selectedCountry != null
                          ? RichText(
                            text: TextSpan(
                              children: [
                                if (decoration?.showFlag ?? true)
                                  TextSpan(
                                    text: "${selectedCountry!.flag} ",
                                    style: TextStyle(
                                      fontSize:
                                          decoration
                                              ?.countryNameTextStyle
                                              ?.fontSize,
                                    ),
                                  ),
                                TextSpan(
                                  text: selectedCountry!.name,
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
    );
  }
}
