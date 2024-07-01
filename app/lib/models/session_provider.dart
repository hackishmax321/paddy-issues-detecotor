import 'package:flutter/material.dart';

class SessionProvider extends ChangeNotifier {
  String? accessToken;
  String? refreshToken;
  DateTime? accessTokenExpireDate;
  DateTime? refreshTokenExpireDate;
  String? userRole;
  int? authEmployeeID;

  void updateSession({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpireDate,
    required DateTime refreshTokenExpireDate,
    required String userRole,
    required int authEmployeeID,
  }) {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.accessTokenExpireDate = accessTokenExpireDate;
    this.refreshTokenExpireDate = refreshTokenExpireDate;
    this.userRole = userRole;
    this.authEmployeeID = authEmployeeID;
    notifyListeners();
  }

  void clearSession() {
    accessToken = null;
    refreshToken = null;
    accessTokenExpireDate = null;
    refreshTokenExpireDate = null;
    userRole = null;
    authEmployeeID = null;
    notifyListeners();
  }
}
