import 'package:flutter/material.dart';
import 'app_strings.dart';

extension LocalizationExtension on BuildContext {
  String translate(String key, [Map<String, String>? parameters]) {
    final languageCode = Localizations.localeOf(this).languageCode;
    var translation = AppStrings.get(key, languageCode);
    
    if (parameters != null) {
      parameters.forEach((paramName, paramValue) {
        translation = translation.replaceAll('{$paramName}', paramValue);
      });
    }
    
    return translation;
  }
}
