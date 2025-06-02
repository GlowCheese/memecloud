import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/stripe/service.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Stripe")),
      body: SizedBox.expand(
        child: Column(
          children: [
            MaterialButton(
              onPressed: () {
                StripeService.instance.makePayment();
              },
              child: const Text("click me"),
            ),
          ],
        ),
      ),
    );
  
  }
}
