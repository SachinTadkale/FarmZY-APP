import 'package:farmzy/shared/models/translation_model.dart';

class MarketRate {
  final String id;
  final String cropName;
  final double currentPrice;
  final double previousPrice;
  final double changePercentage;
  final String location;
  final String mandi;
  final String district;
  final String state;
  final double? minPrice;
  final double? maxPrice;
  final String? variety;
  final String unit;
  final String demandLevel; // HIGH, MEDIUM, LOW
  final String trend; // UP, DOWN, STABLE
  final String? source;
  final EntityTranslations? translations;
  final DateTime? updatedAt;

  const MarketRate({
    required this.id,
    required this.cropName,
    this.variety,
    required this.currentPrice,
    required this.previousPrice,
    required this.changePercentage,
    required this.location,
    required this.mandi,
    required this.district,
    required this.state,
    this.minPrice,
    this.maxPrice,
    this.unit = 'Quintal',
    required this.demandLevel,
    required this.trend,
    this.source,
    this.translations,
    this.updatedAt,
  });

  factory MarketRate.fromJson(Map<String, dynamic> json) {
    // Map backend Prisma fields to frontend model
    final commodity = (json['commodity'] ?? json['cropName'] ?? '').toString();
    final modalPrice = (json['modalPrice'] as num? ?? json['currentPrice'] as num? ?? 0).toDouble();
    final trendPercent = (json['trendPercent'] as num? ?? json['changePercentage'] as num? ?? 0).toDouble();
    
    final mandi = (json['mandiName'] ?? json['mandi'] ?? '').toString();
    final district = (json['district'] ?? '').toString();
    final state = (json['state'] ?? '').toString();
    final locationStr = (json['location'] ?? (mandi.isNotEmpty ? "$mandi, $district" : '')).toString();

    return MarketRate(
      id: (json['id'] ?? '').toString(),
      cropName: commodity,
      variety: json['variety']?.toString(),
      currentPrice: modalPrice,
      previousPrice: (json['previousPrice'] as num? ?? modalPrice).toDouble(),
      changePercentage: trendPercent,
      location: locationStr,
      mandi: mandi,
      district: district,
      state: state,
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      unit: (json['unit'] ?? 'Quintal').toString(),
      demandLevel: (json['demandLevel'] ?? 'MEDIUM').toString().toUpperCase(),
      trend: (json['priceDirection'] ?? json['trend'] ?? (trendPercent > 0 ? 'UP' : trendPercent < 0 ? 'DOWN' : 'STABLE')).toString().toUpperCase(),
      source: json['source']?.toString(),
      translations: json['translations'] != null
          ? EntityTranslations.fromJson(json['translations'] as Map<String, dynamic>)
          : null,
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? json['recordedDate'] ?? '').toString()),
    );
  }
}
