import 'package:flutter/material.dart';
import 'package:flutter_puzzle/page/GamePage.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Puzzle",
        theme: ThemeData.light(),
        home: Scaffold(
          body: HomePage(),
        ));
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GamePage(
        MediaQuery.of(context).size,
        'network',
        'https://cdn.shopify.com/s/files/1/0747/3829/products/mNS0681.jpg?v=1571444655',
        4,
        3);
  }
}
