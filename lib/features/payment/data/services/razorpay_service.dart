import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../constants/razorpay_config.dart';

class RazorpayService {
  late Razorpay _razorpay;
  Function(String paymentId, String orderId)? _onPaymentSuccess;
  Function(String error)? _onPaymentError;
  Function()? _onPaymentCancel;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> initiatePayment({
    required double amount,
    required String description,
    String? orderId,
    Map<String, dynamic>? prefill,
    required Function(String paymentId, String orderId) onSuccess,
    required Function(String error) onError,
    Function()? onCancel,
  }) async {
    if (!RazorpayConfig.isConfigured) {
      onError(RazorpayConfig.configurationError);
      return;
    }

    _onPaymentSuccess = onSuccess;
    _onPaymentError = onError;
    _onPaymentCancel = onCancel;

    final amountInPaise = (amount * 100).toInt();

    var options = {
      'key': RazorpayConfig.keyId,
      'amount': amountInPaise,
      'currency': RazorpayConfig.currency,
      'name': RazorpayConfig.companyName,
      'description': description,
      'timeout': RazorpayConfig.timeout,
      'prefill': prefill ?? {},
    };

    if (orderId != null && orderId.isNotEmpty) {
      options['order_id'] = orderId;
    }

    if (RazorpayConfig.companyLogo.isNotEmpty) {
      options['image'] = RazorpayConfig.companyLogo;
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      onError('Failed to initialize payment: ${e.toString()}');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('✅ Payment Success:');
    debugPrint('   Payment ID: ${response.paymentId}');
    debugPrint('   Order ID: ${response.orderId}');
    debugPrint('   Signature: ${response.signature}');

    if (_onPaymentSuccess != null) {
      _onPaymentSuccess!(
        response.paymentId ?? 'unknown',
        response.orderId ?? 'unknown',
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌ Payment Error:');
    debugPrint('   Code: ${response.code}');
    debugPrint('   Message: ${response.message}');

    if (_onPaymentError != null) {
      final errorMessage = response.message ?? 'Payment failed';
      _onPaymentError!(errorMessage);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('💳 External Wallet:');
    debugPrint('   Wallet Name: ${response.walletName}');

    if (_onPaymentCancel != null) {
      _onPaymentCancel!();
    }
  }

  void dispose() {
    _razorpay.clear();
  }

  Future<void> payForNote({
    required double amount,
    required String noteTitle,
    required String userName,
    required String userEmail,
    required String userPhone,
    required Function(String paymentId, String orderId) onSuccess,
    required Function(String error) onError,
    Function()? onCancel,
  }) async {
    await initiatePayment(
      amount: amount,
      description: 'Purchase: $noteTitle',
      prefill: {
        'name': userName,
        'email': userEmail,
        'contact': userPhone,
      },
      onSuccess: onSuccess,
      onError: onError,
      onCancel: onCancel,
    );
  }

  Future<void> payForCart({
    required double amount,
    required int itemCount,
    required String userName,
    required String userEmail,
    required String userPhone,
    required Function(String paymentId, String orderId) onSuccess,
    required Function(String error) onError,
    Function()? onCancel,
  }) async {
    await initiatePayment(
      amount: amount,
      description: 'Cart Purchase: $itemCount items',
      prefill: {
        'name': userName,
        'email': userEmail,
        'contact': userPhone,
      },
      onSuccess: onSuccess,
      onError: onError,
      onCancel: onCancel,
    );
  }
}
