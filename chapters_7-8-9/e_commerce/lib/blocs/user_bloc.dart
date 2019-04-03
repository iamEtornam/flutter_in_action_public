/*
 * Copyright 2018 Eric Windmill. All rights reserved.
 * Use of this source code is governed by the MIT license that can be found in the LICENSE file.
 */

import 'dart:async';

import 'package:e_commerce/models/events/add_product.dart';
import 'package:e_commerce/models/product.dart';
import 'package:e_commerce/models/user.dart';
import 'package:e_commerce/services/user_service.dart';
import 'package:rxdart/rxdart.dart';

class UserBloc {
  final UserService _service;

  //Inputs
  StreamController<UpdateUserEvent> updateUserInformationSink =
      new StreamController<UpdateUserEvent>();
  StreamController<NewUserProductEvent> addNewProductToUserProductsSink =
      new StreamController<NewUserProductEvent>();

  // Outputs
  Stream<ECommerceUser> get user => _userStreamController.stream;
  StreamController _userStreamController = new BehaviorSubject<ECommerceUser>(
      seedValue: ECommerceUser(
          name: "Eric Windmill", contact: "eric@ericwindmill.com"));

  UserBloc(this._service) {
    updateUserInformationSink.stream.listen(_handleNewUserInformation);
    addNewProductToUserProductsSink.stream.listen(_handleNewUserProduct);
    _service.streamUserInformation().listen((ECommerceUser data) {
      _userStreamController.add(data);
    });
  }

  void _handleNewUserInformation(UpdateUserEvent event) {
    event.user.userProducts = [];
    _service.updateUserInformation(event.user);
  }

  _handleNewUserProduct(NewUserProductEvent event) {
    var product = new Product(
        category: event.product.category,
        title: event.product.title,
        cost: event.product.cost,
        imageTitle: ImageTitle.SlicedOranges); // This
    _service.addUserProduct(product);
  }

  close() {
    updateUserInformationSink.close();
    addNewProductToUserProductsSink.close();
    _userStreamController.close();
  }
}
