import 'package:flutter/foundation.dart';

import './cart.dart';

class OrderItem {
  final String id;
  final double total;
  final List<CartModel> products;
  final DateTime time;

  OrderItem({
    @required this.id,
    @required this.total,
    @required this.products,
    @required this.time,
  });
}

class Orders with ChangeNotifier{
  List<OrderItem> _orders = [];

  List<OrderItem> get orders{
    return [..._orders];
  }

  void addOrder(List<CartModel> cartProducts, double total){
    _orders.insert(0, OrderItem(
        id: DateTime.now().toString(),
        total: total,
        products: cartProducts,
        time: DateTime.now()
    ));

    notifyListeners();
  }
}