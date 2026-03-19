class FarmRequest {
  final String state;
  final String district;
  final String village;
  final String pincode;
  final double? landArea;

  FarmRequest({
    required this.state,
    required this.district,
    required this.village,
    required this.pincode,
    this.landArea,
  });

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'district': district,
      'village': village,
      'pincode': pincode,
      if (landArea != null) 'landArea': landArea,
    };
  }
}
