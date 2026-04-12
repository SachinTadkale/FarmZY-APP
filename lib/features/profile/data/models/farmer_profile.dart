class FarmerProfile {
  final String userId;
  final String name;
  final String email;
  final String role;
  final String actorType;
  final String verificationStatus;

  const FarmerProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.actorType,
    required this.verificationStatus,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    if (parts.isEmpty) {
      return 'F';
    }
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }
}
