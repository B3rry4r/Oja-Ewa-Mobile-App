import 'package:flutter/material.dart';

import '../shell/app_shell.dart';
import '../../features/auth/presentation/screens/create_account_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/password_reset_success_screen.dart';
import '../../features/auth/presentation/screens/new_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/verification_code_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/subfeatures/beauty/presentation/beauty_screen.dart';
import '../../features/home/subfeatures/brands/presentation/brands_screen.dart';
import '../../features/home/subfeatures/market/presentation/market_screen.dart';
import '../../features/home/subfeatures/music/presentation/music_screen.dart';
import '../../features/home/subfeatures/schools/presentation/schools_screen.dart';
import '../../features/home/subfeatures/sustainability/presentation/sustainability_screen.dart';
import '../../features/account/subfeatures/edit_profile/presentation/edit_profile.dart';
import '../../features/account/subfeatures/your_address/presentation/add_edit_address.dart';
import '../../features/account/subfeatures/connect/connect.dart';
import '../../features/account/subfeatures/faq/faq.dart';
import '../../features/account/subfeatures/notifications/presentation/notifications_settings.dart';
import '../../features/account/subfeatures/password/presentation/password.dart';
import '../../features/account/subfeatures/show_your_business/presentation/business_category.dart';
import '../../features/account/subfeatures/show_your_business/presentation/business_onboarding.dart';
import '../../features/account/subfeatures/show_your_business/presentation/business_setting.dart';
import '../../features/account/subfeatures/show_your_business/presentation/business_account_review.dart';
import '../../features/account/subfeatures/show_your_business/presentation/deactivate_shop.dart';
import '../../features/account/subfeatures/show_your_business/presentation/manage_payment.dart';
import '../../features/account/subfeatures/show_your_business/presentation/selected_category_forms/business_seller_registration.dart';
import '../../features/account/subfeatures/show_your_business/presentation/selected_category_forms/beauty/beauty_businiess.dart';
import '../../features/account/subfeatures/show_your_business/presentation/selected_category_forms/brands/brand_business.dart';
import '../../features/account/subfeatures/show_your_business/presentation/selected_category_forms/music/music_business.dart';
import '../../features/account/subfeatures/show_your_business/presentation/selected_category_forms/schools/school_business.dart';
import '../../features/account/subfeatures/start_selling/presentation/account_review.dart';
import '../../features/account/subfeatures/start_selling/presentation/business_details.dart';
import '../../features/account/subfeatures/start_selling/presentation/seller_onboarding.dart';
import '../../features/account/subfeatures/start_selling/presentation/seller_registration.dart';
import '../../features/account/subfeatures/your_address/presentation/your_address.dart';
import '../../features/account/subfeatures/your_order/presentation/order_details.dart';
import '../../features/account/subfeatures/your_order/presentation/tracking_order.dart';
import '../../features/account/subfeatures/your_order/presentation/your_order.dart';
import '../../features/notifications/presentation/notifications.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/cart/presentation/screens/order_confirmation_screen.dart';
import '../../features/review_submission/presentation/review_submission.dart';
import '../../features/product_detail/presentation/reviews.dart';
import '../../features/your_shop/presentation/shop_dashboard.dart';
import '../../features/your_shop/subfeatures/manage_shop/manage_shop.dart';
import '../../features/your_shop/subfeatures/manage_shop/sub_features/delete_shop.dart';
import '../../features/your_shop/subfeatures/manage_shop/sub_features/edit_business.dart';

/// Central place for route names.
abstract class AppRoutes {
  static const home = '/';

  // Auth
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';
  static const createAccount = '/create-account';
  static const resetPassword = '/reset-password';
  static const passwordResetSuccess = '/password-reset-success';
  static const verificationCode = '/verification-code';
  static const newPassword = '/new-password';

  // Home categories
  static const market = '/market';
  static const beauty = '/beauty';
  static const brands = '/brands';
  static const music = '/music';
  static const schools = '/schools';
  static const sustainability = '/sustainability';

  // Feature screens
  static const cart = '/cart';
  static const editProfile = '/edit-profile';
  static const addresses = '/addresses';
  static const addEditAddress = '/add-edit-address';
  static const changePassword = '/change-password';
  static const notificationsSettings = '/notifications-settings';
  static const faq = '/faq';
  static const connectToUs = '/connect-to-us';

  // Business onboarding
  static const businessOnboarding = '/business-onboarding';
  static const businessCategory = '/business-category';
  static const businessSellerRegistration = '/business-seller-registration';
  static const businessBeautyForm = '/business-beauty-form';
  static const businessBrandsForm = '/business-brands-form';
  static const businessSchoolsForm = '/business-schools-form';
  static const businessMusicForm = '/business-music-form';
  static const businessSettings = '/business-settings';
  static const businessAccountReview = '/business-account-review';
  static const deactivateShop = '/deactivate-shop';
  static const managePayment = '/manage-payment';

  // Seller onboarding
  static const sellerOnboarding = '/seller-onboarding';
  static const sellerRegistration = '/seller-registration';
  static const businessDetails = '/business-details';
  static const accountReview = '/account-review';

  static const orders = '/orders';
  static const orderDetails = '/order-details';
  static const trackingOrder = '/tracking-order';
  static const notifications = '/notifications';
  static const reviewSubmission = '/review-submission';
  static const reviews = '/reviews';
  static const orderConfirmation = '/order-confirmation';
  static const yourShopDashboard = '/your-shop-dashboard';
  static const manageShop = '/manage-shop';
  static const editBusiness = '/edit-business';
  static const deleteShop = '/delete-shop';

  /// Temporary route.
  ///
  /// Keep this a plain string (do not reference ScreenGalleryScreen here) to
  /// avoid circular deps that can break Flutter Web hot reload.
  static const gallery = '/_gallery';
}

/// Central place for app routing.
abstract class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );

      case AppRoutes.onboarding:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const OnboardingScreen(),
        );

      case AppRoutes.signIn:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SignInScreen(),
        );

      case AppRoutes.createAccount:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CreateAccountScreen(),
        );

      case AppRoutes.resetPassword:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ResetPasswordScreen(),
        );

      case AppRoutes.verificationCode:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const VerificationCodeScreen(),
        );

      case AppRoutes.newPassword:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const NewPasswordScreen(),
        );

      case AppRoutes.passwordResetSuccess:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const PasswordResetSuccessScreen(),
        );

      case AppRoutes.market:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MarketScreen(),
        );

      case AppRoutes.beauty:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const BeautyScreen(),
        );

      case AppRoutes.brands:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const BrandsScreen(),
        );

      case AppRoutes.music:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MusicScreen(),
        );

      case AppRoutes.schools:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SchoolsScreen(),
        );

      case AppRoutes.sustainability:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SustainabilityScreen(),
        );

      case AppRoutes.editProfile:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const EditProfileScreen(),
        );

      case AppRoutes.addresses:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AddressesScreen(),
        );

      case AppRoutes.addEditAddress:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AddEditAddressScreen(),
        );

      case AppRoutes.changePassword:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ChangePasswordScreen(),
        );

      case AppRoutes.notificationsSettings:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const NotificationsSettingsScreen(),
        );

      case AppRoutes.faq:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const FaqsScreen(),
        );

      case AppRoutes.connectToUs:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ConnectToUsScreen(),
        );

      case AppRoutes.businessOnboarding:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const BusinessOnboardingScreen(),
        );

      case AppRoutes.businessCategory:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const BusinessCategoryScreen(),
        );

      case AppRoutes.businessSellerRegistration:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const BusinessSellerRegistrationScreen(),
        );

      case AppRoutes.businessBeautyForm:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const BeautyBusinessDetailsScreen(),
        );

      case AppRoutes.businessBrandsForm:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const BrandBusinessDetailsScreen(),
        );

      case AppRoutes.businessSchoolsForm:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SchoolBusinessDetailsScreen(),
        );

      case AppRoutes.businessMusicForm:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MusicBusinessDetailsScreen(),
        );

      case AppRoutes.businessSettings:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const BusinessSettingsScreen(),
        );

      case AppRoutes.businessAccountReview:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const BusinessAccountReviewScreen(),
        );

      case AppRoutes.deactivateShop:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const DeactivateShopScreen(),
        );

      case AppRoutes.managePayment:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ManagePaymentScreen(),
        );

      case AppRoutes.sellerOnboarding:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SellerOnboardingScreen(),
        );

      case AppRoutes.sellerRegistration:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SellerRegistrationScreen(),
        );

      case AppRoutes.businessDetails:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const BusinessDetailsScreen(),
        );

      case AppRoutes.accountReview:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AccountReviewScreen(),
        );

      case AppRoutes.orders:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const OrdersScreen(),
        );

      case AppRoutes.orderDetails:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const OrderDetailsScreen(),
        );

      case AppRoutes.trackingOrder:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const TrackingOrderScreen(),
        );

      case AppRoutes.notifications:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const NotificationsScreen(),
        );

      case AppRoutes.cart:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const CartScreen(),
        );

      case AppRoutes.orderConfirmation:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const OrderConfirmationScreen(),
        );

      case AppRoutes.reviewSubmission:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ReviewSubmissionScreen(),
        );

      case AppRoutes.reviews:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ReviewsScreen(),
        );

      case AppRoutes.yourShopDashboard:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ShopDashboardScreen(),
        );

      case AppRoutes.manageShop:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ManageShopScreen(),
        );

      case AppRoutes.editBusiness:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const EditBusinessScreen(),
        );

      case AppRoutes.deleteShop:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const DeleteShopScreen(),
        );

      case AppRoutes.home:
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AppShell(),
        );
    }
  }
}
