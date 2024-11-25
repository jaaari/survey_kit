import 'package:flutter/foundation.dart';
import 'dart:async';


class GlobalStateManager {
  static final GlobalStateManager _instance = GlobalStateManager._internal();

  factory GlobalStateManager() {
    return _instance;
  }

  GlobalStateManager._internal();

  final Map<String, dynamic> _data = {};
  final _stateController = StreamController<Map<String, dynamic>>.broadcast();

  void updateData(Map<String, dynamic> newData) {
    bool hasChanges = false;
    
    newData.forEach((key, value) {
      if (_data[key] != value) {
        _data[key] = value;
        hasChanges = true;
      }
    });
    
    // Only notify listeners if there are actual changes
    if (hasChanges) {
      _stateController.add(_data);
    }
  }

  dynamic getData(String key) => _data[key];
  Map<String, dynamic> getAllData() => Map.from(_data);

  void clear() {
    _data.clear();
    _stateController.add(_data);
  }

  Stream<Map<String, dynamic>> get stream => _stateController.stream;
}
