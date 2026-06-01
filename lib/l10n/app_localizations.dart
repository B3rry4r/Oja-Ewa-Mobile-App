import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_ee.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_rw.dart';
import 'app_localizations_tw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('ee'),
    Locale('en'),
    Locale('fr'),
    Locale('rw'),
    Locale('tw'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get navWishlist;

  /// No description provided for @navBlog.
  ///
  /// In en, this message translates to:
  /// **'Blog'**
  String get navBlog;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get commonSeeAll;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get commonTryAgain;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get commonViewAll;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get authWelcomeBack;

  /// No description provided for @authLetsSignIn.
  ///
  /// In en, this message translates to:
  /// **'Let\'s sign in'**
  String get authLetsSignIn;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get authSignOut;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEmailHint;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Type your password'**
  String get authPasswordHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotPassword;

  /// No description provided for @authRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get authRememberMe;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account yet? '**
  String get authNoAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authCreateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccountTitle;

  /// No description provided for @authFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get authFirstName;

  /// No description provided for @authFirstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get authFirstNameHint;

  /// No description provided for @authLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get authLastName;

  /// No description provided for @authLastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get authLastNameHint;

  /// No description provided for @authPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhone;

  /// No description provided for @authMinChars.
  ///
  /// In en, this message translates to:
  /// **'Minimum of 8 characters'**
  String get authMinChars;

  /// No description provided for @authReferralOptional.
  ///
  /// In en, this message translates to:
  /// **'Referral Code (Optional)'**
  String get authReferralOptional;

  /// No description provided for @authReferralHint.
  ///
  /// In en, this message translates to:
  /// **'Enter referral code'**
  String get authReferralHint;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account? '**
  String get authHaveAccount;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// No description provided for @authGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get authGuest;

  /// No description provided for @authFillFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get authFillFields;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'The Pan-African\nBeauty Market'**
  String get onboardingTitle;

  /// No description provided for @onboardingTerms.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to WAWUBeauty\'s\n'**
  String get onboardingTerms;

  /// No description provided for @onboardingTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get onboardingTermsOfService;

  /// No description provided for @onboardingAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get onboardingAnd;

  /// No description provided for @onboardingPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get onboardingPrivacy;

  /// No description provided for @homeShopByCategory.
  ///
  /// In en, this message translates to:
  /// **'Shop by category'**
  String get homeShopByCategory;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products, brands & shops'**
  String get homeSearchHint;

  /// No description provided for @homeDiscoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover curated drops'**
  String get homeDiscoverTitle;

  /// No description provided for @homeDiscoverSub.
  ///
  /// In en, this message translates to:
  /// **'Fashion, beauty, art, education, and hardware in one marketplace.'**
  String get homeDiscoverSub;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search WAWUBeauty'**
  String get searchHint;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchNoResults;

  /// No description provided for @searchNoResultsSub.
  ///
  /// In en, this message translates to:
  /// **'Try a different term or category.'**
  String get searchNoResultsSub;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search WAWUBeauty'**
  String get searchPrompt;

  /// No description provided for @searchPromptSub.
  ///
  /// In en, this message translates to:
  /// **'Find products, brands and shops across the marketplace.'**
  String get searchPromptSub;

  /// No description provided for @catAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catAll;

  /// No description provided for @catTextiles.
  ///
  /// In en, this message translates to:
  /// **'Textiles'**
  String get catTextiles;

  /// No description provided for @catBeauty.
  ///
  /// In en, this message translates to:
  /// **'Afro Beauty'**
  String get catBeauty;

  /// No description provided for @catShoesBags.
  ///
  /// In en, this message translates to:
  /// **'Shoes & Bags'**
  String get catShoesBags;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @cartEmptySub.
  ///
  /// In en, this message translates to:
  /// **'Browse the marketplace and add items to your cart.'**
  String get cartEmptySub;

  /// No description provided for @cartCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get cartCheckout;

  /// No description provided for @cartSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cartSubtotal;

  /// No description provided for @cartDeliveryNote.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee calculated at checkout'**
  String get cartDeliveryNote;

  /// No description provided for @cartAddToBag.
  ///
  /// In en, this message translates to:
  /// **'Add to Bag'**
  String get cartAddToBag;

  /// No description provided for @cartAtCheckout.
  ///
  /// In en, this message translates to:
  /// **'At checkout'**
  String get cartAtCheckout;

  /// No description provided for @wishlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlistTitle;

  /// No description provided for @wishlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get wishlistEmpty;

  /// No description provided for @wishlistEmptySub.
  ///
  /// In en, this message translates to:
  /// **'Products you save will show up here for quick access later.'**
  String get wishlistEmptySub;

  /// No description provided for @wishlistKeepShopping.
  ///
  /// In en, this message translates to:
  /// **'Keep Shopping'**
  String get wishlistKeepShopping;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Your orders'**
  String get ordersTitle;

  /// No description provided for @ordersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmpty;

  /// No description provided for @ordersEmptySub.
  ///
  /// In en, this message translates to:
  /// **'Your orders will show up here once you check out.'**
  String get ordersEmptySub;

  /// No description provided for @shippingOptions.
  ///
  /// In en, this message translates to:
  /// **'Shipping Options'**
  String get shippingOptions;

  /// No description provided for @shippingLoading.
  ///
  /// In en, this message translates to:
  /// **'Fetching delivery options…'**
  String get shippingLoading;

  /// No description provided for @shippingError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load delivery options'**
  String get shippingError;

  /// No description provided for @accountGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get accountGuest;

  /// No description provided for @accountEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit your profile'**
  String get accountEditProfile;

  /// No description provided for @accountEditProfileSub.
  ///
  /// In en, this message translates to:
  /// **'Name, photo and contact details'**
  String get accountEditProfileSub;

  /// No description provided for @accountYourOrders.
  ///
  /// In en, this message translates to:
  /// **'Your orders'**
  String get accountYourOrders;

  /// No description provided for @accountYourOrdersSub.
  ///
  /// In en, this message translates to:
  /// **'Track and review past orders'**
  String get accountYourOrdersSub;

  /// No description provided for @accountAddresses.
  ///
  /// In en, this message translates to:
  /// **'Your addresses'**
  String get accountAddresses;

  /// No description provided for @accountAddressesSub.
  ///
  /// In en, this message translates to:
  /// **'Delivery locations'**
  String get accountAddressesSub;

  /// No description provided for @accountNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get accountNotifications;

  /// No description provided for @accountNotificationsSub.
  ///
  /// In en, this message translates to:
  /// **'Push and email preferences'**
  String get accountNotificationsSub;

  /// No description provided for @accountPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accountPassword;

  /// No description provided for @accountPasswordSub.
  ///
  /// In en, this message translates to:
  /// **'Change your password'**
  String get accountPasswordSub;

  /// No description provided for @accountSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSectionAccount;

  /// No description provided for @accountSectionBusiness.
  ///
  /// In en, this message translates to:
  /// **'WAWUBeauty Business'**
  String get accountSectionBusiness;

  /// No description provided for @accountSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get accountSectionSupport;

  /// No description provided for @accountStartSelling.
  ///
  /// In en, this message translates to:
  /// **'Start selling'**
  String get accountStartSelling;

  /// No description provided for @accountStartSellingSub.
  ///
  /// In en, this message translates to:
  /// **'List your products and reach buyers'**
  String get accountStartSellingSub;

  /// No description provided for @accountShowBusiness.
  ///
  /// In en, this message translates to:
  /// **'Show your business'**
  String get accountShowBusiness;

  /// No description provided for @accountShowBusinessSub.
  ///
  /// In en, this message translates to:
  /// **'Your heritage and brand story'**
  String get accountShowBusinessSub;

  /// No description provided for @accountEmailUs.
  ///
  /// In en, this message translates to:
  /// **'Email us'**
  String get accountEmailUs;

  /// No description provided for @accountPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get accountPrivacy;

  /// No description provided for @accountTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get accountTerms;

  /// No description provided for @accountFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get accountFaq;

  /// No description provided for @accountConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect to us'**
  String get accountConnect;

  /// No description provided for @accountDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get accountDelete;

  /// No description provided for @blogNoFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorite posts yet'**
  String get blogNoFavorites;

  /// No description provided for @blogNoFavoritesSub.
  ///
  /// In en, this message translates to:
  /// **'Posts you favourite will appear here.'**
  String get blogNoFavoritesSub;

  /// No description provided for @blogNoPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts found'**
  String get blogNoPosts;

  /// No description provided for @blogNoPostsSub.
  ///
  /// In en, this message translates to:
  /// **'Check back soon for new stories.'**
  String get blogNoPostsSub;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You have no notifications'**
  String get notificationsEmpty;

  /// No description provided for @notificationsEmptySub.
  ///
  /// In en, this message translates to:
  /// **'We\'ll let you know when something important happens.'**
  String get notificationsEmptySub;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the language you\'d like to use across WAWUBeauty.'**
  String get languageSubtitle;

  /// No description provided for @productSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get productSize;

  /// No description provided for @productViewSizeChart.
  ///
  /// In en, this message translates to:
  /// **'View Size Chart'**
  String get productViewSizeChart;

  /// No description provided for @productProcessingTime.
  ///
  /// In en, this message translates to:
  /// **'Processing Time'**
  String get productProcessingTime;

  /// No description provided for @productSelectPackage.
  ///
  /// In en, this message translates to:
  /// **'Select your package type'**
  String get productSelectPackage;

  /// No description provided for @productDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescription;

  /// No description provided for @productReturnPolicy.
  ///
  /// In en, this message translates to:
  /// **'Return Policy'**
  String get productReturnPolicy;

  /// No description provided for @productAboutSeller.
  ///
  /// In en, this message translates to:
  /// **'About Seller'**
  String get productAboutSeller;

  /// No description provided for @productYouMayLike.
  ///
  /// In en, this message translates to:
  /// **'You may also like'**
  String get productYouMayLike;

  /// No description provided for @productContactSeller.
  ///
  /// In en, this message translates to:
  /// **'Contact seller'**
  String get productContactSeller;

  /// No description provided for @productUnableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load product details'**
  String get productUnableToLoad;

  /// No description provided for @productAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get productAddedToCart;

  /// No description provided for @productFailedToCart.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to cart'**
  String get productFailedToCart;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Order confirmation'**
  String get checkoutTitle;

  /// No description provided for @checkoutAddAddress.
  ///
  /// In en, this message translates to:
  /// **'Please add a delivery address'**
  String get checkoutAddAddress;

  /// No description provided for @checkoutShippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get checkoutShippingAddress;

  /// No description provided for @checkoutNoAddress.
  ///
  /// In en, this message translates to:
  /// **'No address selected yet'**
  String get checkoutNoAddress;

  /// No description provided for @checkoutAddAddressBtn.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get checkoutAddAddressBtn;

  /// No description provided for @checkoutItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get checkoutItems;

  /// No description provided for @checkoutOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get checkoutOrderSummary;

  /// No description provided for @checkoutDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get checkoutDeliveryFee;

  /// No description provided for @checkoutTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get checkoutTotal;

  /// No description provided for @checkoutPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get checkoutPlaceOrder;

  /// No description provided for @sellerShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Shop'**
  String get sellerShopTitle;

  /// No description provided for @sellerOrdersInProcess.
  ///
  /// In en, this message translates to:
  /// **'Orders in Process'**
  String get sellerOrdersInProcess;

  /// No description provided for @sellerManageShop.
  ///
  /// In en, this message translates to:
  /// **'Manage Shop'**
  String get sellerManageShop;

  /// No description provided for @sellerProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get sellerProducts;

  /// No description provided for @sellerOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get sellerOrders;

  /// No description provided for @sellerView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get sellerView;

  /// No description provided for @sellerSearchShop.
  ///
  /// In en, this message translates to:
  /// **'Search your shop'**
  String get sellerSearchShop;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'ee',
    'en',
    'fr',
    'rw',
    'tw',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'ee':
      return AppLocalizationsEe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'rw':
      return AppLocalizationsRw();
    case 'tw':
      return AppLocalizationsTw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
