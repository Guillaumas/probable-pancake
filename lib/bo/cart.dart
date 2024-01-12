import 'package:epsi_shop/bo/article.dart';
import 'package:flutter/foundation.dart';

class Cart with ChangeNotifier {
  final _items = <Article>[];

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  String priceTotalInEuro() {
    double total = _items.fold(0.0, (itemPrev, item) => itemPrev + item.prix);
    return "${(total).toStringAsFixed(2)} €";
  }

  double calculateSubtotal() {
    return _items.fold(0, (total, current) => total + current.prix);
  }

  //String priceTotalInEuroSimpl() {
  //  var prix = 0 as num;
  //  for (Article item in _items) {
  //    prix+= item.prix;
  //  }
  //  return "$prix€";
  //}
  List<Article> get items => _items;
  //<Article>[].fold(0 as num, (previousValue, element) => previousValue + element.prix)

  void addArticle(Article article) {
    _items.add(article);
    notifyListeners();
  }

  void removeArticle(Article article) {
    _items.remove(article);
    notifyListeners();
  }

}
