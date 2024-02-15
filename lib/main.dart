import 'package:flutter/material.dart';
import 'package:flutter_in_app_purchase_demo/screens/buy_coins.dart';
import 'package:flutter_in_app_purchase_demo/screens/splash.dart';
import 'package:flutter_in_app_purchase_demo/screens/subscriptions.dart';
import 'package:onepref/onepref.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OnePref.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Flutter demo",
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter in app purchase"),
      ),
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
            onTap: () => {
              Navigator.of(context).push(MaterialPageRoute(builder: (builder) => const BuyCoins()))
            },
            child: const Text("Buy coins")),
            const Divider(),
            GestureDetector(
            onTap: () => {
              Navigator.of(context).push(MaterialPageRoute(builder: (builder) => const Subscriptions()))
            },
            child: const Text("Subscriptions")),
          ]
        ),
        ),
      );
  }
}
