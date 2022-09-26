import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.https(
        'myshop-69fe2-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/oders.json');
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if(extractedData == null){
      return;
    }
    extractedData.forEach((orderID, orderItem) {
      loadedOrders.add(OrderItem(
          id: orderID,
          total: orderItem['total'],
          time: DateTime.parse(orderItem['time']),
          products: (orderItem['products'] as List<dynamic>).map((item) {
            CartModel(id: item['id'], title: item['title'], quantity: item['quantity'], price: item['price']);
          }).toList()
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartModel> cartProducts, double total) async {
    final url = Uri.https(
        'myshop-69fe2-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/oders.json');
    final dateTime = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'total': total,
          'time': dateTime.toIso8601String(),
          'products': cartProducts
              .map((product) => {
                    'id': product.id,
                    'title': product.title,
                    'quantity': product.quantity,
                    'price': product.price
                  })
              .toList()
        }));
    _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'],
            total: total,
            products: cartProducts,
            time: dateTime));
    notifyListeners();
  }
}
