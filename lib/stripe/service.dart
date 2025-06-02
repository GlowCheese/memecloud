import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/stripe/const.dart';

Future<void> stripeSetup() async {
  Stripe.publishableKey = stripePublishableKey;
  await Stripe.instance.applySettings();
}

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<void> makePayment() async {
    try {
      String? paymentIntentClientSecret = await _createPaymentIntent(2, 'usd');
      log('payment $paymentIntentClientSecret');
      if (paymentIntentClientSecret == null) return;
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "memecloud",
        ),
      );
      await _processPayment();
    } on StripeConfigException catch (_, e) {
      log('error when make payment ${e.toString()}');
    }
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final dio = getIt<Dio>();
      Map<String, dynamic> data = {
        'amount': _calculateAmount(amount),
        'currency': currency,
      };
      var response = await dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Authorization': 'Bearer $stripeSecretKey',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );
      if (response.data == null) {
        return 'khong co';
      }
      return response.data['client_secret'];
    } catch (e) {
      log('error when  createpaymentintent ${e.toString()}');
    }
    return null;
  }

  Future<void> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      await Stripe.instance.confirmPaymentSheetPayment();
    } catch (e) {
      log('error when  processpayment ${e.toString()}');
    }
  }

  String _calculateAmount(int amount) {
    amount *= 100;
    return amount.toString();
  }
}
