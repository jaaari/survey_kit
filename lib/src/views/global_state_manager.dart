class GlobalStateManager {
  static final GlobalStateManager _instance = GlobalStateManager._internal();

  factory GlobalStateManager() {
    return _instance;
  }

  GlobalStateManager._internal();

  final Map<String, dynamic> _data = {};

  // Updated to merge data
  void updateData(Map<String, dynamic> newData) {
    _data.addAll(newData);
  }

  dynamic getData(String key) {
    return _data[key];
  }

  Map<String, dynamic> getAllData() {
    return Map.from(_data); // Return a copy to prevent external modification
  }

  void clearData() {
    _data.clear();
  }
}
