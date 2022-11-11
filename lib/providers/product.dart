import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier{
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
      @required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavourite = false});

  Future<void> toggleFavouriteStatus(String authToken, String userId) async{
    final url = Uri.parse(
        'https://myshop-69fe2-default-rtdb.asia-southeast1.firebasedatabase.app/userFavourites/$userId/$id.json?auth=$authToken');
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    try{
      final response = await http.put(url,body: json.encode(
        isFavourite,
      ));
      if(response.statusCode>=400){
        isFavourite = oldStatus;
        notifyListeners();
      }
    }catch(error){
      isFavourite = oldStatus;
      notifyListeners();
    }
  }
}