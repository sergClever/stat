
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stat/localization/demo_localization.dart';

  const String ENGLISH = "en";
  const String SPANISH = "es";
  const String LANGUAGE_CODE = "languageCode";


  String getTranslated(BuildContext context, String key) {
    return DemoLocalization.of(context).getTranslatedValue(key);
  }

  // initial setup for setting language code 
  Future<Locale> setLocale(String languageCode) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    
    await _prefs.setString(LANGUAGE_CODE, languageCode);

    return _locale(languageCode);
  }

  // Choose language code and return 
  Locale _locale(String languageCode) {
    Locale _temp;

    switch (languageCode) {
      case ENGLISH:
        _temp = Locale(languageCode, "US");
        break;
      case SPANISH:
        _temp = Locale(languageCode, "MX");
        break;
      default: 
        _temp = Locale(ENGLISH, "US");
    }

    return _temp;
  }

  // When user comes back to get users language code
  Future<Locale> getLocale() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    
    String languageCode = _prefs.getString(LANGUAGE_CODE) ?? ENGLISH;

    return _locale(languageCode);
  }