import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/material.dart';
import 'package:onepref/onepref.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class BuyCoins extends StatefulWidget {
  const BuyCoins({super.key});

  @override
  State<BuyCoins> createState() => _BuyCoinsState();
}

class _BuyCoinsState extends State<BuyCoins> {

//Llista de prodcutes.

late final List<ProductDetails> _products = <ProductDetails>[];

//IApEngine

IApEngine iApEngine = IApEngine();

//Llista de IDs de productes.

List<ProductId> storeProductsIDs = <ProductId>[
  ProductId(id: 'coins_10', isConsumable: true, reward: 10),
  ProductId(id: 'coins_20', isConsumable: true, reward: 20),
  ProductId(id: 'coins_50', isConsumable: true, reward: 50)


];
int reward = 0;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    iApEngine.inAppPurchase.purchaseStream.listen((list){
      listenPurchases(list);
    });
    getProducts();
    reward = OnePref.getInt('coins') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$reward'),),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) => 
          GestureDetector(
            onTap: () async => {
              iApEngine.handlePurchase(_products[index], storeProductsIDs)
            },
            child: ListTile(
              title: Text(
                _products[index].description
              ),
              trailing: Text(
                _products[index].price
              ),
            ),
          )
        )
      );
  }

void getProducts() async{
  await iApEngine.getIsAvailable().then((value) async{
    if (value){
      await iApEngine.queryProducts(storeProductsIDs).then((response){
        //print(response.notFoundIDs);
        setState(() {
          _products.addAll(response.productDetails);
        });
      });
    }
  });
}



  Future<void> listenPurchases(List<PurchaseDetails> list) async {
    for (PurchaseDetails purchase in list) {
      if(purchase.status== PurchaseStatus.restored || purchase.status== PurchaseStatus.purchased){
        if (Platform.isAndroid && iApEngine
                                  .getProductIdsOnly(storeProductsIDs)
                                  .contains(purchase.productID)){

                                    final InAppPurchaseAndroidPlatformAddition androidAddition = iApEngine
                                          .inAppPurchase
                                          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

                                  }
        if (purchase.pendingCompletePurchase){
          await iApEngine.inAppPurchase.completePurchase(purchase);
        }
        // delivery the product
        giveUserCoins(purchase);
      }
    }
  }

  void giveUserCoins (PurchaseDetails purchaseDetails){
    reward = OnePref.getInt('coins') ?? 0;
    for (var product in storeProductsIDs) {
      if (product.id == purchaseDetails.productID){
        setState(() {
          reward =reward + product.reward!;
          OnePref.setInt('coins', reward);
        });
      }
    }
  }

}