import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/cart.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  static var _expanded = false;

  @override
  Widget build(BuildContext context) {
    List<CartModel> itemList = widget.order.products;
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('\$${widget.order.total}'),
            subtitle: Text(
              DateFormat('dd/MM/yyyy hh:mm').format(widget.order.time),
            ),
            // trailing: IconButton(
            //   icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            //   onPressed: () {
            //     setState(() {
            //       _expanded = !_expanded;
            //     });
            //   },
            // ),
          ),
          if (_expanded)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: min(itemList.length * 20.0 + 10, 100),
              child: ListView(
                children: itemList.map((prod) => Row(  // Here prod is does not contain anything unfortunately
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        prod.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${prod.quantity} x \$${prod.price}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  )).toList(),
              ),
            )
        ],
      ),
    );
  }
}
