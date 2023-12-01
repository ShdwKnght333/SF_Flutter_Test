import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sf_auth_test/Classes/auth_token.dart';

Map convertResponseToMap(var response) {
  var responseString = response.body;
  var responseJSON = jsonDecode(responseString) as Map;
  return responseJSON;
}

void storeToken(AuthToken token) {
  const storage = FlutterSecureStorage();
  storage.write(key: "AuthToken", value: json.encode(AuthToken.toMap(token)));
}


Future<AuthToken> getTokenFromStorage() async {
  const storage = FlutterSecureStorage();
  String? tokenString;
  AuthToken token;
  bool isAuthorized = await getBiometricAuthentication();
  
  if(isAuthorized) {
    tokenString = await storage.read(key: "AuthToken") as String;
    if(tokenString.isNotEmpty) {
      token = AuthToken.fromJson(jsonDecode(tokenString));
    }
    else {
      token = AuthToken.fakeToken();
    }
  }
  else {
    print("Authorization failed");
    token = AuthToken.fakeToken();
  }
  return token;
}

Future<bool> getBiometricAuthentication() async {
  bool isAuthenticated = false;
  LocalAuthentication localAuth = LocalAuthentication();
  List<BiometricType> availableBiometrics = await localAuth.getAvailableBiometrics();
  if(availableBiometrics.isNotEmpty) {
    isAuthenticated = await localAuth.authenticate(
      localizedReason: "Authenticate to refresh Token",
      // options: const AuthenticationOptions(biometricOnly: true),
    );
  }
  return isAuthenticated;
}