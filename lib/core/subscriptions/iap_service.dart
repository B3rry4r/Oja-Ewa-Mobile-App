import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import 'package:ojaewa/features/app_services/shared/domain/app_service_purchase.dart';

import 'subscription_constants.dart';
import 'subscription_controller.dart';
import 'subscription_models.dart';

/// IAP Service
///
/// Handles all In-App Purchase operations with Apple App Store and Google Play Store.
/// Communicates purchase results to the backend for verification and storage.
class IapService {
  IapService(this._ref);

  final Ref _ref;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _isInitialized = false;
  // De-dupes concurrent initialize() calls. The provider fires initialize()
  // without awaiting it, so a fast purchase tap can call it again before the
  // first finishes — without this guard each call would attach another
  // purchaseStream listener (double-delivery) and re-query products.
  Future<void>? _initFuture;
  Completer<AppServicePurchase?>? _servicePurchaseCompleter;
  String? _pendingServiceProductId;
  // Human-readable reason the last service purchase returned null, so the UI
  // can show "Store unavailable"/"canceled"/etc. instead of a blanket
  // "Payment was not completed".
  String? _lastServiceError;

  /// Whether IAP is available on this device
  bool get isAvailable => _isAvailable;

  /// Reason the most recent purchaseService() returned null, if any.
  String? get lastServiceError => _lastServiceError;

  /// Available products loaded from the store
  List<ProductDetails> get products => _products;

  /// Initialize the IAP service.
  ///
  /// Idempotent and safe to call concurrently: the first in-flight run is
  /// shared by later callers, so we never attach a second purchaseStream
  /// listener. If the store reports unavailable, _isInitialized stays false so
  /// a later call (e.g. from ensureReady) retries the connection.
  Future<void> initialize() {
    if (_isInitialized) return Future.value();
    return _initFuture ??= _doInitialize();
  }

  Future<void> _doInitialize() async {
    try {
      _isAvailable = await _iap.isAvailable();

      if (!_isAvailable) {
        debugPrint('IAP: Store not available on this device');
        return;
      }

      // Enable pending purchases for Android
      if (Platform.isAndroid) {
        _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        // Pending purchases are enabled by default in newer versions
        // No explicit call needed
      }

      // Listen for purchase updates
      _purchaseSubscription = _iap.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () => _purchaseSubscription?.cancel(),
        onError: (error) => debugPrint('IAP Purchase Stream Error: $error'),
      );

      // Load products
      await loadProducts();

      _isInitialized = true;
      debugPrint('IAP: Initialized successfully');
    } finally {
      _initFuture = null;
    }
  }

  /// Make sure the store connection is up and products are loaded before a
  /// purchase is attempted. The provider kicks off initialize() without
  /// awaiting it, so a quick tap can race ahead of init — surfacing as a
  /// spurious "Payment was not completed". Re-running init here is idempotent
  /// (deduped via _initFuture) and closes that race.
  Future<void> ensureReady() async {
    if (!_isInitialized) {
      await initialize();
    }
    // isAvailable() can transiently report false on a cold start; re-check.
    if (!_isAvailable) {
      _isAvailable = await _iap.isAvailable();
    }
    // Products may not have loaded yet (or the first query returned none).
    if (_isAvailable && _products.isEmpty) {
      await loadProducts();
    }
  }

  /// Load products from the store
  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    final response = await _iap.queryProductDetails(
      StoreProductCatalog.allProducts.toSet(),
    );

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('IAP: Products not found: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
    debugPrint('IAP: Loaded ${_products.length} products');
  }

  /// Get a specific product by ID
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  /// Purchase a subscription
  Future<bool> purchaseSubscription(String productId) async {
    // Same init-race guard as purchaseService: ensure the store is up and
    // products are loaded before attempting a buy.
    await ensureReady();

    if (!_isAvailable) {
      debugPrint('IAP: Store not available');
      return false;
    }

    final product = getProduct(productId);
    if (product == null) {
      debugPrint('IAP: Product not found: $productId');
      return false;
    }

    // Set loading state immediately when purchase starts
    _ref.read(subscriptionControllerProvider.notifier).setLoading(true);

    final purchaseParam = PurchaseParam(productDetails: product);

    try {
      // For subscriptions, use buyNonConsumable
      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      debugPrint('IAP: Purchase initiated: $success');

      // If purchase initiation failed, clear loading state
      if (!success) {
        _ref.read(subscriptionControllerProvider.notifier).setLoading(false);
      }
      return success;
    } catch (e) {
      debugPrint('IAP: Purchase error: $e');
      // Clear loading state on error
      _ref
          .read(subscriptionControllerProvider.notifier)
          .setLoading(false, error: e.toString());
      return false;
    }
  }

  Future<AppServicePurchase?> purchaseService(String productId) async {
    _lastServiceError = null;

    // Close the init race: the provider fires initialize() without awaiting,
    // so on a cold start a fast tap could land here before the store was
    // available or products were loaded — returning null and showing the
    // misleading "Payment was not completed". Wait for readiness first.
    await ensureReady();

    if (!_isAvailable) {
      debugPrint('IAP: Store not available');
      _lastServiceError =
          'In-app purchases are not available on this device right now. '
          'Please try again in a moment.';
      return null;
    }

    final product = getProduct(productId);
    if (product == null) {
      debugPrint('IAP: Service product not found: $productId');
      _lastServiceError =
          'This badge is not available for purchase right now. '
          'Please try again shortly.';
      return null;
    }

    if (_servicePurchaseCompleter != null) {
      debugPrint('IAP: Service purchase already in progress');
      _lastServiceError = 'A purchase is already in progress.';
      return null;
    }

    final completer = Completer<AppServicePurchase?>();
    _servicePurchaseCompleter = completer;
    _pendingServiceProductId = productId;

    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      // Badge products are auto-renewing yearly subscriptions in the stores,
      // so use buyNonConsumable (which the in_app_purchase plugin also uses
      // for subscriptions). buyConsumable would acknowledge+consume the token
      // on Android, breaking renewal.
      final success = await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      if (!success) {
        _clearPendingServicePurchase();
        _lastServiceError =
            'The store could not start the purchase. Please try again.';
        return null;
      }
      return completer.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          _clearPendingServicePurchase();
          _lastServiceError =
              'The purchase timed out before it completed. If you were '
              'charged it will be restored automatically.';
          return null;
        },
      );
    } catch (e) {
      _clearPendingServicePurchase();
      debugPrint('IAP: Service purchase error: $e');
      _lastServiceError = 'Something went wrong starting the purchase.';
      return null;
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;

    await _iap.restorePurchases();
  }

  /// Handle purchase updates from the store
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      debugPrint(
        'IAP: Purchase update - ${purchase.productID}: ${purchase.status}',
      );

      switch (purchase.status) {
        case PurchaseStatus.pending:
          // Show loading/pending UI
          _onPurchasePending(purchase);
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (_isPendingServicePurchase(purchase.productID)) {
            final result = await _buildAppServicePurchase(purchase);
            _servicePurchaseCompleter?.complete(result);
            _clearPendingServicePurchase();
          } else {
            // Verify with backend and deliver content
            await _verifyAndDeliverPurchase(purchase);
          }
          break;

        case PurchaseStatus.error:
          _onPurchaseError(purchase);
          break;

        case PurchaseStatus.canceled:
          _onPurchaseCanceled(purchase);
          break;
      }

      // Complete the purchase (important for Android)
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  /// Verify purchase with backend and deliver content
  Future<void> _verifyAndDeliverPurchase(PurchaseDetails purchase) async {
    try {
      String receiptData;
      String transactionId;
      bool isSandbox = false;

      if (Platform.isIOS) {
        // iOS: Get receipt data
        final skPurchase = purchase as AppStorePurchaseDetails;
        receiptData = skPurchase.verificationData.localVerificationData;
        transactionId = skPurchase.purchaseID ?? purchase.purchaseID ?? '';

        // Check if sandbox
        final transactions = await SKPaymentQueueWrapper().transactions();
        isSandbox = transactions.any(
          (t) =>
              t.transactionIdentifier == transactionId &&
              t.payment.simulatesAskToBuyInSandbox,
        );
      } else {
        // Android: Get purchase token
        final googlePurchase = purchase as GooglePlayPurchaseDetails;
        receiptData = googlePurchase.verificationData.serverVerificationData;
        transactionId = googlePurchase.purchaseID ?? purchase.purchaseID ?? '';
      }

      // Verify with backend
      final response = await _ref
          .read(subscriptionControllerProvider.notifier)
          .verifyPurchase(
            productId: purchase.productID,
            transactionId: transactionId,
            receiptData: receiptData,
            isSandbox: isSandbox,
          );

      if (response?.success == true) {
        debugPrint('IAP: Purchase verified successfully');
        _onPurchaseSuccess(purchase, response!);
      } else {
        debugPrint('IAP: Purchase verification failed: ${response?.message}');
        _onVerificationFailed(purchase, response);
      }
    } catch (e) {
      debugPrint('IAP: Verification error: $e');
      _onVerificationFailed(purchase, null);
    }
  }

  void _onPurchasePending(PurchaseDetails purchase) {
    debugPrint('IAP: Purchase pending for ${purchase.productID}');
    // Set loading state to show spinner on subscribe buttons
    _ref.read(subscriptionControllerProvider.notifier).setLoading(true);
  }

  void _onPurchaseSuccess(
    PurchaseDetails purchase,
    VerifyPurchaseResponse response,
  ) {
    debugPrint('IAP: Purchase success for ${purchase.productID}');
    // Subscription status is refreshed by the controller
    // UI will update automatically via Riverpod
  }

  void _onPurchaseError(PurchaseDetails purchase) {
    debugPrint(
      'IAP: Purchase error for ${purchase.productID}: ${purchase.error}',
    );
    if (_isPendingServicePurchase(purchase.productID)) {
      _lastServiceError = purchase.error?.message.isNotEmpty == true
          ? purchase.error!.message
          : 'The payment could not be completed. Please try again.';
      _servicePurchaseCompleter?.complete(null);
      _clearPendingServicePurchase();
    }
    // Clear loading state and show error
    _ref
        .read(subscriptionControllerProvider.notifier)
        .setLoading(false, error: purchase.error?.message);
  }

  void _onPurchaseCanceled(PurchaseDetails purchase) {
    debugPrint('IAP: Purchase canceled for ${purchase.productID}');
    if (_isPendingServicePurchase(purchase.productID)) {
      _lastServiceError = 'Payment was canceled.';
      _servicePurchaseCompleter?.complete(null);
      _clearPendingServicePurchase();
    }
    // Clear loading state - user canceled
    _ref.read(subscriptionControllerProvider.notifier).setLoading(false);
  }

  void _onVerificationFailed(
    PurchaseDetails purchase,
    VerifyPurchaseResponse? response,
  ) {
    debugPrint('IAP: Verification failed for ${purchase.productID}');
    // Error should be shown to user - handled by subscription controller
  }

  /// Dispose of resources
  void dispose() {
    _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
    _isInitialized = false;
  }

  bool _isPendingServicePurchase(String productId) {
    return _pendingServiceProductId != null &&
        _pendingServiceProductId == productId &&
        _servicePurchaseCompleter != null;
  }

  void _clearPendingServicePurchase() {
    _pendingServiceProductId = null;
    _servicePurchaseCompleter = null;
  }

  Future<AppServicePurchase> _buildAppServicePurchase(
    PurchaseDetails purchase,
  ) async {
    final product = getProduct(purchase.productID);
    String transactionId = purchase.purchaseID ?? '';
    String? receiptData;
    String? purchaseToken;
    String environment = 'production';

    if (Platform.isIOS) {
      final skPurchase = purchase as AppStorePurchaseDetails;
      receiptData = skPurchase.verificationData.localVerificationData;
      transactionId = skPurchase.purchaseID ?? purchase.purchaseID ?? '';
      final transactions = await SKPaymentQueueWrapper().transactions();
      final isSandbox = transactions.any(
        (t) =>
            t.transactionIdentifier == transactionId &&
            t.payment.simulatesAskToBuyInSandbox,
      );
      environment = isSandbox ? 'sandbox' : 'production';
    } else if (Platform.isAndroid) {
      final googlePurchase = purchase as GooglePlayPurchaseDetails;
      receiptData = googlePurchase.verificationData.serverVerificationData;
      transactionId = googlePurchase.purchaseID ?? purchase.purchaseID ?? '';
      purchaseToken = googlePurchase.verificationData.serverVerificationData;
    }

    return AppServicePurchase(
      platform: Platform.isIOS ? 'ios' : 'android',
      storeProductId: purchase.productID,
      storeTransactionId: transactionId,
      purchaseToken: purchaseToken,
      receiptData: receiptData,
      environment: environment,
      currency: product?.currencyCode,
      amount: product?.rawPrice,
      rawData: {
        'local_verification_data':
            purchase.verificationData.localVerificationData,
        'server_verification_data':
            purchase.verificationData.serverVerificationData,
        'source': purchase.verificationData.source,
      },
    );
  }
}

/// Provider for IAP Service
final iapServiceProvider = Provider<IapService>((ref) {
  final service = IapService(ref);

  // Initialize on first access
  service.initialize();

  // Dispose when no longer needed
  ref.onDispose(() => service.dispose());

  return service;
});

/// Provider for IAP availability
final iapAvailableProvider = Provider<bool>((ref) {
  final iap = ref.watch(iapServiceProvider);
  return iap.isAvailable;
});

/// Provider for available products
final iapProductsProvider = Provider<List<ProductDetails>>((ref) {
  final iap = ref.watch(iapServiceProvider);
  return iap.products;
});

/// Get a specific product by ID
final iapProductProvider = Provider.family<ProductDetails?, String>((
  ref,
  productId,
) {
  final iap = ref.watch(iapServiceProvider);
  return iap.getProduct(productId);
});
