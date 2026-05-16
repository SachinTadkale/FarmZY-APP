/**
 * Module: Vehicle Profile Request
 * Purpose: Implements the Vehicle Profile Request module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
/**
 * Vehicle Profile Request.
 */
class VehicleProfileRequest {
  final String vehicleType;
  final String vehicleNumber;
  final String licenseNumber;
  final double capacity;

  const VehicleProfileRequest({
    required this.vehicleType,
    required this.vehicleNumber,
    required this.licenseNumber,
    required this.capacity,
  });

/**
 * To Json.
 */
  Map<String, dynamic> toJson() {
    return {
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'licenseNumber': licenseNumber,
      'capacity': capacity,
    };
  }
}
