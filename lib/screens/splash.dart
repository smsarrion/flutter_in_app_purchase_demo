
import 'package:flutter/material.dart';
import 'package:flutter_in_app_purchase_demo/main.dart';
import 'package:onepref/onepref.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

IApEngine iApEngine = IApEngine();

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    restoreSub();

    iApEngine.inAppPurchase.purchaseStream.listen((list) { 
      if (list.isNotEmpty){
        //restore subscription
        for (var subs in list) {
          print (subs.verificationData.localVerificationData);
        }
        OnePref.setPremium(true);
      }
      else{
        // do nothing, or deactivate the subscription if the user is premium.
        OnePref.setPremium(false);
      }
      Navigator.of(context).
      pushReplacement(MaterialPageRoute(builder: (builder) => const MyHomePage()));

    });
  }


  void restoreSub(){
    iApEngine.inAppPurchase.restorePurchases();
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Loading...')),
    );
  }
}