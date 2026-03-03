import 'package:flutter/material.dart';

enum DeepLinkDestination { profile, post }

class DeepLinkData {
  final DeepLinkDestination destination;
  final String? id;

  DeepLinkData({required this.destination, this.id});
}

class DeepLinkProvider extends ChangeNotifier {
  DeepLinkData? _pending;
  DeepLinkData? get pending => _pending;

  void handle(DeepLinkData data) {
    _pending = data;
    notifyListeners();
  }

  void consume() {
    _pending = null;
  }
}
