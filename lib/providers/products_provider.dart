import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'product.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  var _showFavouritesOnly = false;

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favouriteItems {
    return _items.where((element) => element.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.https(
        'myshop-69fe2-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/products.json');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if(extractedData == null){
        return;
      }
      extractedData.forEach((prodID, prodData) {
        loadedProducts.add(Product(
            id: prodID,
            title: prodData['title'],
            description: prodData['description'],
            price: double.parse(prodData['price']),
            imageUrl: prodData['imageUrl'],
            isFavourite: prodData['isFavourite'] == true ? true : false ));
        _items = loadedProducts;
      });
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final url = Uri.https(
          'myshop-69fe2-default-rtdb.asia-southeast1.firebasedatabase.app',
          '/products.json');
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'price': product.price.toString(),
            'description': product.description,
            'imageUrl': product.imageUrl,
            'isFavourite': product.isFavourite.toString()
          }));

      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);

      _items.add(newProduct);
      //_items.insert(0, newProduct); //at the beginning
      notifyListeners();
    } catch (error) {
      print(error+" in add product");
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(
          'myshop-69fe2-default-rtdb.asia-southeast1.firebasedatabase.app',
          '/products/$id.json');
      http.patch(url, body: json.encode({
        'title': product.title,
        'price': product.price.toString(),
        'description': product.description,
        'imageUrl': product.imageUrl
      }));
      _items[prodIndex] = product;
      notifyListeners();
    } else {
      print("no id");
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https(
        'myshop-69fe2-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/products/$id.json');
    final existingProductIndex = _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];
    final response = await http.delete(url);
    _items.removeAt(existingProductIndex );
    notifyListeners();
      if(response.statusCode>=400){
        _items.insert(existingProductIndex, existingProduct);
        notifyListeners();
        throw HttpException("Could not delete product in deleteProduct function.");
      }
      existingProduct = null;



  }
}
