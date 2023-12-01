class AuthToken {
  String accessToken;
  String refreshToken;
  String tokenType;
  String subDomain;
  String apiCP;
  String appCP;

  AuthToken({
    required this.accessToken, 
    required this.refreshToken,
    required this.tokenType,
    required this.subDomain,
    required this.apiCP,
    required this.appCP,
  });

  @override
  String toString() {
    String data = '''
AuthToken Info
SubDomain         : $subDomain
AccessToken       : ${accessToken.substring(0, 10)}...<Redacted Information>
RefreshToken      : ${refreshToken.substring(0, 10)}...<Redacted Information>
Token Type        : $tokenType
API Control Plane : $apiCP
App Control Plane : $appCP
  ''';
    return data;
  }

  factory AuthToken.fromJson(Map<String, dynamic> jsonData) => AuthToken(
    accessToken: jsonData["authToken"] as String, 
    refreshToken: jsonData["refreshToken"] as String, 
    tokenType: jsonData["tokenType"] as String, 
    subDomain: jsonData["subDomain"] as String, 
    apiCP: jsonData["apiCP"] as String, 
    appCP: jsonData["appCP"] as String,
  );

  static Map<String, String> toMap(AuthToken token) => <String, String> {
    "authToken" : token.accessToken,
    "refreshToken": token.refreshToken,
    "tokenType": token.tokenType,
    "subDomain": token.subDomain,
    "apiCP": token.apiCP,
    "appCP": token.appCP,
  };

  String urlForToken() {
    String url;
    if(apiCP.endsWith(".com")) {
      url = "https://$subDomain.$apiCP/sf/v3";
    }
    else {
      url = "https://$subDomain.$apiCP.com/sf/v3";
    }
    return url;
  }

  bool isFake() {
    bool isFakeToken = false;
    AuthToken fakeToken = AuthToken.fakeToken();
    if(accessToken  == fakeToken.accessToken &&
       refreshToken == fakeToken.refreshToken &&
       tokenType    == fakeToken.tokenType &&
       subDomain    == fakeToken.subDomain &&
       apiCP        == fakeToken.apiCP &&
       appCP        == fakeToken.appCP) {
      isFakeToken = true;
    }
    return isFakeToken;
  }

  static AuthToken fakeToken() {
    AuthToken tempToken = AuthToken(accessToken: "accessToken", refreshToken: "refreshToken", tokenType: "tokenType", subDomain: "subDomain", apiCP: "apiCP", appCP: "appCP");
    return tempToken;
  }

}