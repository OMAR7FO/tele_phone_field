import "dart:async";
import "package:custom_phone_field/countries.dart";
import "package:custom_phone_field/country_code_decoration.dart";
import "package:custom_phone_field/country_container.dart";
import "package:custom_phone_field/country_dialog_picker.dart";
import "package:custom_phone_field/helpers.dart";
import "package:custom_phone_field/matched_countries_result.dart";
import "package:custom_phone_field/phone_number.dart";
import "package:flutter/material.dart";

//Todo add the backspace action
class CustomPhoneField extends StatefulWidget {
  final bool obscureText;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final bool autoFocus;
  final bool readOnly;
  final String? invalidCountryMessage;
  final FormFieldSetter<PhoneNumber>? onSaved;
  final ValueChanged<PhoneNumber>? onChanged;
  final ValueChanged<CountryPhone> onCountryChanged;
  final FutureOr<String?> Function(PhoneNumber?)? validator;
  final TextInputType keyboardType;
  final InputDecoration decoration;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final AutovalidateMode? autoValidateMode;
  final Brightness? keyboardAppearance;
  final String? initialValue;
  final String languageCode;
  final String? initialCountryCode;
  final List<CountryPhone>? countries;
  final TextStyle? style;
  final bool disableLengthCheck;
  final bool showCountryFlag;
  final String? invalidNumberMessage;
  final Color? cursorColor;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final double cursorWidth;
  final bool? showCursor;
  final TextEditingController? phoneNumberController;
  final TextEditingController? countryCodeController;
  final double? countryContainerWidth;
  final double countryContainerHeight;
  final CountryCodeDecoration? countryContainerDecoration;
  final Color? dividerColor;
  final double? dividerWidth;
  final double? paddingBetweenCountryContainerAndPhoneField;
  final PickerDialogStyle? pickerDialogStyle;
  final CountryCodeSize countryCodeSize;

  const CustomPhoneField({
    super.key,
    this.paddingBetweenCountryContainerAndPhoneField,
    this.invalidCountryMessage,
    this.pickerDialogStyle,
    this.countryContainerWidth,
    required this.countryContainerHeight,
    this.countryContainerDecoration,
    required this.onCountryChanged,
    this.dividerColor,
    this.dividerWidth,
    this.phoneNumberController,
    this.countryCodeSize = CountryCodeSize.five,
    this.disableLengthCheck = false,
    this.countryCodeController,
    this.decoration = const InputDecoration(),
    this.initialCountryCode,
    this.languageCode = 'en',
    this.obscureText = false,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.onTap,
    this.readOnly = false,
    this.initialValue,
    this.keyboardType = TextInputType.phone,
    this.style,
    this.onSaved,
    this.onSubmitted,
    this.validator,
    this.onChanged,
    this.countries,
    this.enabled = true,
    this.autoValidateMode = AutovalidateMode.onUserInteraction,
    this.keyboardAppearance,
    this.autoFocus = false,
    this.textInputAction,
    this.cursorColor,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorWidth = 2.0,
    this.showCursor = true,
    this.invalidNumberMessage,
    this.showCountryFlag = true,
  });
  @override
  State<CustomPhoneField> createState() => _CustomPhoneFieldState();
}

class _CustomPhoneFieldState extends State<CustomPhoneField> {
  late List<CountryPhone> _countryList;
  late List<CountryPhone> filteredCountries;

  late String number;
  late TextEditingController _countryCodeController;
  late TextEditingController _countryPhoneController;
  String? validatorMessage;
  CountryPhone? _selectedCountry;
  FocusNode phoneFocusNode = FocusNode();
  FocusNode countryCodeFocusNode = FocusNode();
  String hintText = "";
  @override
  void initState() {
    super.initState();
    _countryList = widget.countries ?? countries;
    filteredCountries = _countryList;
    number = widget.initialValue ?? "";
    _countryCodeController =
        widget.countryCodeController ?? TextEditingController();
    _countryPhoneController = widget.phoneNumberController ??
        TextEditingController(text: widget.initialValue);
    if (widget.initialCountryCode == null && number.startsWith('+')) {
      number = number.substring(1);
      _selectedCountry = countries.firstWhere(
        (country) => number.startsWith(country.fullCountryCode),
        orElse: () => _countryList.first,
      );
      _countryCodeController.text = _selectedCountry!.dialCode;
      number = number.replaceFirst(
        RegExp("^${_selectedCountry?.fullCountryCode}"),
        "",
      );
    } else {
      _selectedCountry = _countryList.firstWhere(
        (country) => country.code == (widget.initialCountryCode ?? 'US'),
        orElse: () => _countryList.first,
      );
      _countryCodeController.text = _selectedCountry!.dialCode;
      if (number.startsWith('+')) {
        number = number.replaceFirst(
          RegExp("^\\+${_selectedCountry!.fullCountryCode}"),
          '',
        );
      } else {
        number = number.replaceFirst(
          RegExp("^${_selectedCountry!.fullCountryCode}"),
          "",
        );
      }
    }
    if (widget.autoValidateMode == AutovalidateMode.always) {
      final initialPhoneNumber = PhoneNumber(
        countryISOCode: _selectedCountry!.code,
        countryCode: _selectedCountry!.code,
        number: widget.initialValue ?? '',
      );
      final value = widget.validator?.call(initialPhoneNumber);
      if (value is String) {
        validatorMessage = value;
      } else {
        (value as Future).then((msg) {
          validatorMessage = msg;
        });
      }
    }
    _countryCodeController.addListener(() {
      if (_countryCodeController.text.length > 4) {
        String code = _countryCodeController.text;
        _countryCodeController.text = code.substring(0, 1);
        _countryPhoneController.text = code.substring(1, 5);
        FocusScope.of(context).requestFocus(phoneFocusNode);
      }
    });
  }

  void _onCountryCodeChanged(String code) {
    MatchedCountriesResult result = checkIfThereIsMatchedCountry(code: code);
    _changeSelectedCountry(
      country: result.matchedCountry,
      requestFocus: !result.moreThanOneCountryFound,
    );
  }

  MatchedCountriesResult checkIfThereIsMatchedCountry({required String code}) {
    List<CountryPhone> matchedCountries = countries
        .where((CountryPhone country) => country.dialCode.startsWith(code))
        .toList();
    try {
      late CountryPhone matchedCountry;
      if (code == "1") {
        matchedCountry = matchedCountries.firstWhere(
          (CountryPhone country) => country.code == "US",
        );
      } else {
        matchedCountry = matchedCountries.firstWhere(
          (CountryPhone country) => country.dialCode == code,
        );
      }
      return MatchedCountriesResult(
        moreThanOneCountryFound: matchedCountries.length > 1,
        matchedCountry: matchedCountry,
      );
    } catch (err) {
      return MatchedCountriesResult(
        moreThanOneCountryFound: matchedCountries.length > 1,
      );
    }
  }

  @override
  void dispose() {
    _countryCodeController.dispose();
    _countryPhoneController.dispose();
    phoneFocusNode.dispose();
    countryCodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CountryContainer(
          selectedCountry: _selectedCountry,
          width: widget.countryContainerWidth,
          height: widget.countryContainerHeight,
          decoration: widget.countryContainerDecoration,
          onTap: () async {
            filteredCountries = _countryList;
            await showDialog(
              context: context,
              useRootNavigator: false,
              builder: (context) => CountryPickerDialog(
                languageCode: widget.languageCode.toLowerCase(),
                style: widget.pickerDialogStyle,
                filteredCountries: filteredCountries,
                searchText: "Search Country",
                countryList: _countryList,
                selectedCountry: _selectedCountry,
                onCountryChanged: (CountryPhone? country) {
                  _changeSelectedCountry(country: country);
                },
              ),
            );
          },
        ),
        SizedBox(
          height: widget.paddingBetweenCountryContainerAndPhoneField ?? 12,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return TextFormField(
              readOnly: widget.readOnly,
              obscureText: widget.obscureText,
              textAlign: widget.textAlign,
              textAlignVertical: widget.textAlignVertical,
              cursorHeight: widget.cursorHeight,
              cursorRadius: widget.cursorRadius,
              showCursor: widget.showCursor,
              style: widget.style,
              maxLength: _selectedCountry?.maxLength,
              cursorWidth: widget.cursorWidth,
              enabled: widget.enabled,
              keyboardAppearance: widget.keyboardAppearance,
              autofocus: widget.autoFocus,
              textInputAction: widget.textInputAction,
              autovalidateMode: widget.autoValidateMode,
              focusNode: phoneFocusNode,
              controller: _countryPhoneController,
              keyboardType: TextInputType.number,
              cursorColor: widget.cursorColor,
              onFieldSubmitted: widget.onSubmitted,
              onSaved: (value) {
                widget.onSaved?.call(
                  PhoneNumber(
                    countryISOCode: _selectedCountry?.code ?? "Unkown",
                    countryCode: '+${_countryCodeController.text}',
                    number: value!,
                  ),
                );
              },
              validator: (value) {
                if (_selectedCountry == null) {
                  //Todo remove the static text
                  return widget.invalidCountryMessage ?? "Invalid Country";
                }
                if (value == null || !isNumeric(value)) {
                  return widget.invalidNumberMessage ?? "Invalid Number";
                }
                if (!widget.disableLengthCheck) {
                  return value.length >= _selectedCountry!.minLength &&
                          value.length <= _selectedCountry!.maxLength
                      ? null
                      : widget.invalidNumberMessage;
                }
                return validatorMessage;
              },
              onChanged: (String value) async {
                final phoneNumber = PhoneNumber(
                  countryISOCode: _selectedCountry?.code ?? "Unkown",
                  countryCode: '+${_countryCodeController.text}',
                  number: value,
                );
                if (widget.autoValidateMode != AutovalidateMode.disabled) {
                  validatorMessage = await widget.validator?.call(phoneNumber);
                }
                widget.onChanged?.call(phoneNumber);
              },
              decoration: widget.decoration.copyWith(
                hintText: _selectedCountry == null
                    ? widget.decoration.hintText
                    : List.generate(
                        _selectedCountry!.maxLength,
                        (index) => '0',
                      ).join(),
                prefixIcon: _buildCountryCodeTextField(constraints),
              ),
            );
          },
        ),
      ],
    );
  }

  void _changeSelectedCountry({
    required CountryPhone? country,
    bool requestFocus = true,
  }) {
    _selectedCountry = country;
    if (_selectedCountry != null) {
      _countryCodeController.text = _selectedCountry!.dialCode;
      widget.onCountryChanged(_selectedCountry!);
      if (requestFocus) {
        FocusScope.of(context).requestFocus(phoneFocusNode);
      }
    }
    setState(() {});
  }

  Widget _buildCountryCodeTextField(BoxConstraints constraints) {
    return IntrinsicHeight(
      child: Padding(
        padding: widget.decoration.contentPadding ??
            EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('+', style: widget.style),
            SizedBox(
              width: constraints.maxWidth / widget.countryCodeSize.size,
              child: TextFormField(
                focusNode: countryCodeFocusNode,
                cursorColor: widget.cursorColor,
                style: widget.style,
                cursorWidth: widget.cursorWidth,
                keyboardType: TextInputType.number,
                controller: _countryCodeController,
                onChanged: _onCountryCodeChanged,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: true),
              ),
            ),
            VerticalDivider(
              width: widget.dividerWidth,
              thickness: 1,
              color: widget.dividerColor,
              indent: 10,
              endIndent: 10,
            ),
          ],
        ),
      ),
    );
  }
}

enum CountryCodeSize { one, two, three, four, five, six, seven }

extension CountryCodeWidth on CountryCodeSize {
  int get size {
    switch (this) {
      case CountryCodeSize.one:
        return 1;
      case CountryCodeSize.two:
        return 2;
      case CountryCodeSize.three:
        return 3;
      case CountryCodeSize.four:
        return 4;
      case CountryCodeSize.five:
        return 5;
      case CountryCodeSize.six:
        return 6;
      case CountryCodeSize.seven:
        return 7;
    }
  }
}
