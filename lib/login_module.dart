import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sf_auth_test/Classes/auth_token.dart';
import 'package:sf_auth_test/Classes/helpers.dart';

Future<String> initalURL(var subDomain) async {
  String scope = "sharefile:restapi:v3 openid profile sharefile:account offline_access";
  String state = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk";
  String codeChallenge = await _getCodeChallenge();
  String sha256 = _getSHA256(codeChallenge);
  String url = "https://auth.sharefiletest.io/connect/authorize?response_type=code&client_id=sharFileMobileTest&redirect_uri=sharefile://sharefileAuth.com&scope=$scope&code_challenge=$sha256&code_challenge_method=S256&state=$state";
  if(subDomain != null) {
    url = "$url&acr_values=idp:sharefiletest tenant:$subDomain";
  }
  return url;
}

Future<String> _getCodeChallenge() async {
  Random random = Random();
  List<int> bytes = List.generate(32, (index) => random.nextInt(256));
  String codeChallenge = base64UrlEncode(bytes);
  while(codeChallenge.endsWith('=')) {
    codeChallenge = codeChallenge.substring(0, codeChallenge.length - 1);
  }
  const storage = FlutterSecureStorage();
  await storage.write(key: "CodeChallenge", value: codeChallenge);
  return codeChallenge;
}

String _getSHA256(String code) {
  List<int> bytes = utf8.encode(code);
  Hash codeSHA256 = sha256;
  Digest digest = codeSHA256.convert(bytes);
  String sha256String = base64UrlEncode(digest.bytes);
  while(sha256String.endsWith('=')) {
    sha256String = sha256String.substring(0, sha256String.length - 1);
  }
  return sha256String;
}

Future<AuthToken> executeTokenCall(String url) async {
  var tokenUrl = Uri.https("auth.sharefiletest.io" , "connect/token");
  String? tokenCode = getCodeFromUrl(url);
  String? codeChallenge = await getCodeChallengeFromStorage();

  var tokenBody = {
    "grant_type" : "authorization_code",
    "code" : tokenCode,
    "redirect_uri" : "sharefile://sharefileAuth.com", 
    "client_id" : "sharFileMobileTest",
    "code_verifier" : codeChallenge
  };

  var response = await http.post(tokenUrl, body: tokenBody);

  AuthToken newToken = getAuthTokenFromResponse(convertResponseToMap(response));
  print(newToken.toString());
  storeToken(newToken);
  return newToken;
}

String? getCodeFromUrl(String url) {
  Uri uri = Uri.parse(url);
  String? tokenCode = uri.queryParameters["code"];
  return tokenCode;
}

Future<String?> getCodeChallengeFromStorage() async {
  const storage = FlutterSecureStorage();
  String? code = await storage.read(key: "CodeChallenge");
  storage.delete(key: "CodeChallenge");
  return code;
}

AuthToken getAuthTokenFromResponse(Map response) {

  String api = "sf-apitest.com";
  String app = "sharefiletest.com";
  String subdomain = getSubdomainFromAccessToken(response["access_token"]);
  return AuthToken(
    accessToken: response["access_token"], 
    refreshToken: response["refresh_token"], 
    tokenType: response["token_type"],
    subDomain: subdomain, 
    apiCP: api, 
    appCP: app);
}

String getSubdomainFromAccessToken(String token) {
  String accessToken = token.split('.')[1];
  int padLength = (4 - (accessToken.length % 4) % 4);
  while(padLength != 0) {
    accessToken = '$accessToken=';
    padLength--;
  }
  var decodedData = base64Decode(accessToken);
  Map tokenMap = jsonDecode(utf8.decode(decodedData));
  String subDomain = tokenMap["sharefile:subdomain"];
  return subDomain;
}

Future<AuthToken> executeRefreshCall(String token) async {
  if(token == "refreshToken") {
    print("Fake Token received, cant be refershed!");
    return AuthToken.fakeToken();
  }
  else {
    var tokenUrl = Uri.https("auth.sharefiletest.io" , "connect/token");
    var tokenBody = {
      "grant_type" : "refresh_token",
      "refresh_token" : token,
      "client_id" : "sharFileMobileTest",
    };

    var response = await http.post(tokenUrl, body: tokenBody);

    AuthToken newToken = getAuthTokenFromResponse(convertResponseToMap(response));
    print(newToken.toString());
    storeToken(newToken);
    return newToken;
  }
}