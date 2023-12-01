import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sf_auth_test/Classes/auth_token.dart';
import 'package:sf_auth_test/Classes/helpers.dart';
import 'package:sf_auth_test/Classes/user.dart';
import 'package:sf_auth_test/login_module.dart';

class UserHomePage extends StatefulWidget {
  final AuthToken userToken;
  const UserHomePage({super.key, required this.userToken});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  bool userLoaded = false;
  late User currentUser = User(id: "1", accountId: "2", name: "Fake", token: widget.userToken);
  String personalFolder = "PersonalFolders";
  String sharedFolder = "SharedFodlers";

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    if(userLoaded) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Hi ${currentUser.name}!"),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: null, 
                child: const Text("Take a picture")
              ),
              const SizedBox(width: 10, height: 10,),
              ElevatedButton(
                onPressed: refreshAuthToken, 
                child: const Text("Refresh Token"),
              ),
            ],
          ),
        ),
      );
    }
    else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => {
                  Navigator.pop(context)
                },
                child: const Text("Press Me to go Back"),
              ),
              const SizedBox(width: 10, height: 10,),
              ElevatedButton(
                onPressed: refreshAuthToken, 
                child: const Text("Refresh Token"),
              ),
            ],
          )
        ),
      );
    }
  }

  void getUserData() async {
    AuthToken token = widget.userToken;
    String userCall = "${token.urlForToken()}/Sessions/Login?\$expand=Principal";
    Uri url = Uri.parse(userCall);

    Map<String, String> headers = {
      "Authorization": "${token.tokenType} ${token.accessToken}",
    };
    var response = await http.get(url, headers: headers);
    Map sessionsResponse = convertResponseToMap(response);
    if(sessionsResponse["Principal"] != null) {
      setState(() {
        currentUser = User(id: sessionsResponse["Principal"]["Id"], accountId: sessionsResponse["Id"], name: sessionsResponse["Principal"]["FirstName"], token: token);
        getFolders();
      });
    }
  }

  void refreshAuthToken() async {
    AuthToken? token = await getTokenFromStorage();
    token = await executeRefreshCall(token.refreshToken);
    setState(() {
      currentUser.token = token as AuthToken;
    });
  }
  
  void getFolders() async {
    String folderCall = "${currentUser.token.urlForToken()}/Items(top)?\$expand=Children&includeDeleted=False";
    Uri url = Uri.parse(folderCall);
    Map<String, String> headers = {
      "Authorization": "${currentUser.token.tokenType} ${currentUser.token.accessToken}",
    };
    var response = await http.get(url, headers: headers);
    Map sessionsResponse = convertResponseToMap(response);
    List children = sessionsResponse["Children"];
    if(children[0] != null) {
      Map folder = children[0];
      if(folder["Id"] != null) {
        setState(() {
          personalFolder = children[0]["Id"];
          userLoaded = true;
          print(personalFolder);
        });
      }
    }
  }
}