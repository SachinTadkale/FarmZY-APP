/**
 * Module: Farmer Profile
 * Purpose: Implements the Farmer Profile module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
/**
 * Farmer Profile.
 */
class FarmerProfile {
  final String userId;
  final String name;
  final String? email;
  final String role;
  final String verificationStatus;
  final String? profileImage;
  final String? location;
  final int cropCount;
  final int listingCount;
  final int orderCount;
  final double revenue;
  final String? publicProfileId;
  final String? qrShareToken;

  const FarmerProfile({
    required this.userId,
    required this.name,
    this.email,
    required this.role,
    required this.verificationStatus,
    this.profileImage,
    this.location,
    this.cropCount = 0,
    this.listingCount = 0,
    this.orderCount = 0,
    this.revenue = 0.0,
    this.publicProfileId,
    this.qrShareToken,
  });

  factory FarmerProfile.fromJson(Map<String, dynamic> json) {
    return FarmerProfile(
      userId: json['user_id'] ?? json['id'] ?? '',
      name: (json['name'] != null && json['name'].toString().isNotEmpty) 
          ? json['name'] 
          : (json['fullName'] != null && json['fullName'].toString().isNotEmpty)
              ? json['fullName']
              : 'Farmer',
      email: json['email'],
      role: json['role'] ?? 'FARMER',
      verificationStatus: json['verificationStatus'] ?? 'PENDING',
      profileImage: json['profileImage'],
      location: json['location'],
      cropCount: json['cropCount'] ?? 0,
      listingCount: json['listingCount'] ?? 0,
      orderCount: json['orderCount'] ?? 0,
      revenue: (json['revenue'] ?? 0.0).toDouble(),
      publicProfileId: json['publicProfileId'],
      qrShareToken: json['qrShareToken'],
    );
  }

  String get initials {
    if (name.isEmpty) return 'F';
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    if (parts.isEmpty) return 'F';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }
}
