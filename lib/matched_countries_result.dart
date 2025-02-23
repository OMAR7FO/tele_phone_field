import "package:custom_phone_field/countries.dart";

class MatchedCountriesResult {
  final CountryPhone? matchedCountry;
  final bool moreThanOneCountryFound;
  MatchedCountriesResult({
    this.matchedCountry,
    required this.moreThanOneCountryFound,
  });
}
