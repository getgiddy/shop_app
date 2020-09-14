import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/order.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

import 'providers/cart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (context) => Products.empty(),
            update: (context, value, previous) => Products(
              value.token,
              value.userId,
              previous == null ? [] : previous.items,
            ),
          ),
          ChangeNotifierProvider.value(
            value: Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Order>(
            create: (context) => Order.empty(),
            update: (context, value, previous) => Order(
              value.token,
              value.userId,
              previous == null ? [] : previous.orders,
            ),
          )
        ],
        child: Consumer<Auth>(
          builder: (context, auth, child) => MaterialApp(
            title: 'Shop App',
            theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange,
                fontFamily: 'Lato',
                visualDensity: VisualDensity.adaptivePlatformDensity,
                pageTransitionsTheme: PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: CustomPageTransitionsBuilder(),
                    TargetPlatform.iOS: CustomPageTransitionsBuilder(),
                  },
                )),
            home: auth.isAuth
                ? ProductsOverViewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (context, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              ProductDetailScreen.route: (context) => ProductDetailScreen(),
              CartScreen.route: (context) => CartScreen(),
              OrdersScreen.route: (context) => OrdersScreen(),
              UserProductsScreen.route: (context) => UserProductsScreen(),
              EditProductScreen.route: (context) => EditProductScreen(),
            },
          ),
        ));
  }
}
