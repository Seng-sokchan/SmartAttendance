import 'package:flutter/foundation.dart';

import '../models/create_user_models.dart';
import '../models/user_list_item.dart';
import '../services/api_service.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider(this._api);

  final ApiService _api;

  List<UserListItem> _users = [];
  List<UserListItem> get users => List.unmodifiable(_users);

  bool _loading = false;
  bool get loading => _loading;

  Future<void> loadUsers() async {
    _loading = true;
    notifyListeners();
    try {
      _users = await _api.getUsers();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createUser(CreateUserRequest request) async {
    _loading = true;
    notifyListeners();
    try {
      await _api.createUser(request);
      _users = await _api.getUsers();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
