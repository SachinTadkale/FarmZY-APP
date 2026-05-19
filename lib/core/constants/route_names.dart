/**
 * Module: Route Names
 * Purpose: Implements the Route Names module for the FarmZy mobile app.
 * Note: Documentation-only change; behavior remains unchanged.
 */
import 'package:farmzy/shared/enums/user_role.dart';

/**
 * Route Names.
 */
class RouteNames {
  static const splash = '/';
  static const languageSelection = '/language-selection';
  static const roleSelection = '/role-selection';
  static const home = '/home';
  static const farmerHome = '/farmer/home';
  static const deliveryHome = '/delivery/home';
  static const deliveryJobs = '/delivery/jobs';
  static const deliveryDeliveries = '/delivery/active';
  static const deliveryWallet = '/delivery/wallet';
  static const marketplace = '/marketplace';
  static const myCrops = '/my-crops';
  static const orders = '/orders';
  static const orderDetail = '/orders/:id';
  static const profile = '/profile';
  static const register = '/register';
  static const farmerRegister = '/register/farmer';
  static const deliveryRegister = '/register/delivery';
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const verificationPending = '/verification-pending';
  static const transactionHistory = '/transaction-history';
  static const forgotPassword = '/forgot-password';
  static const otpVerification = '/otp-verification';
  static const resetPassword = '/reset-password';
  static const settings = '/settings';
  static const profileQr = '/profile/qr';
  static const aiChat = '/ai-chat';
  static const news = '/news';
  static const help = '/help';
  static const marketRates = '/market-rates';
  static const listingDetail = '/marketplace/:id';
  static const maintenance = '/maintenance';

  static String homeForRole(UserRole role) {
    return switch (role) {
      UserRole.deliveryPartner => deliveryHome,
      UserRole.farmer || UserRole.admin || UserRole.owner => farmerHome,
    };
  }
}
