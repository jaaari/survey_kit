import 'package:flutter/foundation.dart';


class GlobalStateManager {
  static final GlobalStateManager _instance = GlobalStateManager._internal();

  factory GlobalStateManager() {
    return _instance;
  }

  GlobalStateManager._internal();

  final Map<String, dynamic> _data = {};
  final List<VoidCallback> _listeners = [];

  void updateData(Map<String, dynamic> newData) {
    print('GlobalStateManager - Previous state: $_data');
    _data.addAll(newData);
    print('GlobalStateManager - Updated state: $_data');
    print('GlobalStateManager - Changed values: $newData');
    _notifyListeners();
  }

  dynamic getData(String key) {
    return _data[key];
  }

  Map<String, dynamic> getAllData() {
    return Map.from(_data); // Return a copy to prevent external modification
  }

  void clearData() {
    _data.clear();
    _notifyListeners();
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);  
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
}