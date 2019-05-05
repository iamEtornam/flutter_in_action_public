import 'dart:async';

import 'translator.dart';

void main() {
  var burgerStand = new GoodBurgerRestaurant();
  burgerStand.turnOnTranslator();

  burgerStand.newOrder(555);
  burgerStand.newOrder(121);
  burgerStand.newOrder(1253);
  burgerStand.newOrder(3);
  burgerStand.newOrder(887);
  burgerStand.newOrder(66);
}

class GoodBurgerRestaurant {
  Cook cook = new Cook();
  StreamController _controller = new StreamController.broadcast();

  Stream get onNewBurgerOrder => _controller.stream;

  void turnOnTranslator() {
    onNewBurgerOrder
        .transform(new BeepBoopTranslator())
        .listen((data) => cook.prepareOrder(data));
  }

  void newOrder(int orderNum) {
    _controller.add(orderNum);
  }
}

class Cook {
  void prepareOrder(newOrder) {
    print("preparing meal $newOrder");
  }
}
