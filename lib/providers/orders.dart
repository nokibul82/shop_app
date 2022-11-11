import 'dart:convert';

import 'package:flutter/foundation.dart';
import './product.dart';
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
  final String authToken;
  List<OrderItem> _orders = [];
  final String userId;

  Orders(this.authToken,this.userId,this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    print("AuthToken : $authToken");
    final url = Uri.parse('https://myshop-69fe2-default-rtdb.asia-southeast1.firebasedatabase.app/oders/$userId.json?auth=$authToken');
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderID, orderData) {
      loadedOrders.add(OrderItem(
          id: orderID,
          total: orderData['total'],
          products: (orderData['products'] as List<dynamic>).map((item) {
            CartModel(
                id: item["id"],
                title: item["title"],
                quantity: item["quantity"],
                price: item["price"]);
          }).toList(),
          time: DateTime.parse(orderData['time'])
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartModel> cartProducts, double total) async {
    final url = Uri.parse('https://myshop-69fe2-default-rtdb.asia-southeast1.firebasedatabase.app/oders/$userId.json?auth=$authToken');
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
