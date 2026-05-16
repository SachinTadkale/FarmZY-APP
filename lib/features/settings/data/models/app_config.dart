class FeatureConfig {
  final bool enabled;
  final bool visible;

  const FeatureConfig({
    required this.enabled,
    required this.visible,
  });

  factory FeatureConfig.fromJson(Map<String, dynamic> json) {
    return FeatureConfig(
      enabled: json['enabled'] ?? false,
      visible: json['visible'] ?? false,
    );
  }

  factory FeatureConfig.fallback({bool enabled = true, bool visible = true}) {
    return FeatureConfig(enabled: enabled, visible: visible);
  }
}

class AppConfig {
  final bool maintenanceMode;
  final bool readOnlyMode;
  final Map<String, FeatureConfig> features;
  final DateTime? cachedAt;

  const AppConfig({
    required this.maintenanceMode,
    required this.readOnlyMode,
    required this.features,
    this.cachedAt,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final featuresMap = <String, FeatureConfig>{};
    if (json['features'] != null) {
      (json['features'] as Map<String, dynamic>).forEach((key, value) {
        featuresMap[key] = FeatureConfig.fromJson(value as Map<String, dynamic>);
      });
    }

    return AppConfig(
      maintenanceMode: json['maintenanceMode'] ?? false,
      readOnlyMode:    json['readOnlyMode'] ?? false,
      features:        featuresMap,
      cachedAt:        json['_cachedAt'] != null ? DateTime.tryParse(json['_cachedAt'].toString()) : null,
    );
  }

  factory AppConfig.fallback() {
    return AppConfig(
      maintenanceMode: false,
      readOnlyMode:    false,
      features: {
        'marketplace': FeatureConfig.fallback(),
        'orders':      FeatureConfig.fallback(),
        'payments':    FeatureConfig.fallback(),
        'delivery':    FeatureConfig.fallback(),
        'marketRates': FeatureConfig.fallback(),
        'ai':          FeatureConfig.fallback(enabled: false, visible: true),
        'news':        FeatureConfig.fallback(enabled: false, visible: true),
        'qr':          FeatureConfig.fallback(enabled: false, visible: false),
      },
    );
  }

  bool isEnabled(String featureKey) {
    return features[featureKey]?.enabled ?? false;
  }

  bool isVisible(String featureKey) {
    return features[featureKey]?.visible ?? false;
  }
}
