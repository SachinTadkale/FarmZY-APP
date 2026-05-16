/**
 * Module: Translation Model
 * Purpose: Provides a standardized way to handle multilingual strings from the backend.
 */

class TranslationModel {
  final Map<String, dynamic> translations;

  const TranslationModel(this.translations);

  /**
   * Get translation for a specific language code.
   * Falls back to the original text if translation is missing.
   */
  String get(String lang, {required String original}) {
    final entry = translations[lang];
    if (entry == null || entry.toString().isEmpty) {
      return original;
    }
    return entry.toString();
  }

  factory TranslationModel.fromJson(Map<String, dynamic>? json) {
    return TranslationModel(json ?? {});
  }
}

/**
 * Entity Translations.
 * A collection of translated fields for a specific entity (e.g. name, category).
 */
class EntityTranslations {
  final Map<String, TranslationModel> fields;

  const EntityTranslations(this.fields);

  /**
   * Get translated text for a field in a specific language.
   */
  String getTranslatedField(String field, String lang, {required String original}) {
    return fields[field]?.get(lang, original: original) ?? original;
  }

  factory EntityTranslations.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EntityTranslations({});
    
    final fields = <String, TranslationModel>{};
    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        fields[key] = TranslationModel.fromJson(value);
      }
    });
    
    return EntityTranslations(fields);
  }
}
