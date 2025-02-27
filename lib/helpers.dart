import "package:custom_phone_field/countries.dart";

bool isNumeric(String s) =>
    s.isNotEmpty && int.tryParse(s.replaceAll("+", "")) != null;

String removeDiacritics(String str) {
  String withDia =
      "ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž";
  String withoutDia =
      "AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz";

  for (int i = 0; i < withDia.length; i++) {
    str = str.replaceAll(withDia[i], withoutDia[i]);
  }

  return str;
}

extension CountryExtensions on List<CountryPhone> {
  List<CountryPhone> stringSearch(String search) {
    search = removeDiacritics(search.toLowerCase());
    return where(
      (CountryPhone country) => isNumeric(search) || search.startsWith("+")
          ? country.dialCode.contains(search)
          : removeDiacritics(
                country.name.replaceAll("+", "").toLowerCase(),
              ).contains(search) ||
              country.nameTranslations.values.any(
                (String element) => removeDiacritics(
                  element.toLowerCase(),
                ).contains(search),
              ),
    ).toList();
  }
}
