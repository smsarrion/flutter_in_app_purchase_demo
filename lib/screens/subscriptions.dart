import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:onepref/onepref.dart';

class Subscriptions extends StatefulWidget {
  const Subscriptions({super.key});

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> {

  //List of products subscription
    late final List<ProductDetails> _products = <ProductDetails>[];
  //List of products Ids.
    late final List<ProductId> _productsIds = <ProductId>[
      ProductId(id: "annual_subscription", isConsumable: false),
      ProductId(id: "biannual_subscription", isConsumable: false),
      ProductId(id: "quarterly_subscription", isConsumable: false),
      //ProductId(id: "mensual_subscription", isConsumable: false),

    ];
  //iAppEngine
    IApEngine iApEngine = IApEngine();
  //bool
    bool isSubscribed = false;

@override
  void initState()  {
    // TODO: implement initState
    super.initState();
    // listen to our purchase events / restore
    iApEngine.inAppPurchase.purchaseStream.listen((listOfPurchaseDetails){
      listenPurchases(listOfPurchaseDetails);
    });


    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: ((context,index){
        return GestureDetector(
          child: ListTile(
            onTap: () => {
              iApEngine.handlePurchase(_products[index], _productsIds)
            },
            title: Text(_products[index].description),
            trailing: Text(_products[index].price),),
        );
      })),
    );
  }
  
  void getProducts() async{
    await iApEngine.getIsAvailable().then((value) async {
      if (value){
        await iApEngine.queryProducts(_productsIds).then((res){
          print(res.notFoundIDs);
          _products.clear();
          setState(() {
            _products.addAll(res.productDetails);
          });
        });
      }
    });
  }
  
Future<void> listenPurchases(List<PurchaseDetails> list) async {
  if (list.isNotEmpty){
    for (PurchaseDetails purchaseDetails in list) {
      if (purchaseDetails.status == PurchaseStatus.restored || 
          purchaseDetails.status == PurchaseStatus.purchased){
            print (purchaseDetails.verificationData.localVerificationData);
            Map purchaseData = json
              .decode(purchaseDetails.verificationData.localVerificationData);

            if (purchaseData['acknowledge']){
              print('Restore purchase');
              setState(() {
                isSubscribed = true;
                OnePref.setPremium(isSubscribed);
              });
            }else{
              print('First time purchase');
              // Android consume
              if (Platform.isAndroid){
                final InAppPurchaseAndroidPlatformAddition androidPlatformAddition = 
                  iApEngine.inAppPurchase
                  .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
                await androidPlatformAddition.consumePurchase(purchaseDetails)
                .then((value) {
                  updateIsSub(true);
                });
              }
              //complete
              if (purchaseDetails.pendingCompletePurchase){
                await iApEngine.inAppPurchase.completePurchase(purchaseDetails).then((value) {
                    updateIsSub(true);
                });
              }

            }
      }
    }
  }else{
    updateIsSub(false);
  }
}

void updateIsSub(bool value){
  setState(() {
    isSubscribed = value;
    OnePref.setPremium(isSubscribed);
  });
}

}