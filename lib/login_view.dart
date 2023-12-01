import 'package:flutter/material.dart';
import 'package:sf_auth_test/Classes/auth_token.dart';
import 'package:sf_auth_test/loggedin_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'login_module.dart';

class LoginWebPage extends StatefulWidget {
  const LoginWebPage({super.key});

  @override
  State<LoginWebPage> createState() => _LoginWebPageState();
}

class _LoginWebPageState extends State<LoginWebPage> {
  late final WebViewController controller;
  var loadingPer = 0;
  bool closePage = false;
  String loginUrl = "https://secure.sharefiletest.com";
  AuthToken loginToken = AuthToken.fakeToken();

  @override
  void initState() {
    super.initState();
    fetchLoginUrl();
    controller = WebViewController()
      ..loadRequest(Uri.parse(loginUrl))
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (uri) {
          setState(() {
            loadingPer = 0;
          });
        },
        onProgress: (progress) {
          setState(() {
            loadingPer = progress;
          });
        },
        onPageFinished: (uri) {
          setState(() {
            loadingPer = 100;
          });
        },
        onUrlChange: (navigation) {
          var navUrl = navigation.url;
          if(navUrl != null  && navUrl.startsWith("sharefile://")) {
            fetchToken(navUrl);
          }
        }
      )
    );
  }

  Future<void> fetchLoginUrl() async {
    var url = await initalURL(null);
    controller.loadRequest(Uri.parse(url));
    setState(() {
      loginUrl = url;
    });
  }

  Future<void> fetchToken (String url) async {
    AuthToken newToken = await executeTokenCall(url);
    setState(() {
      loginToken = newToken;
      closePage = true;
    });
  }

  @override
  Widget build (BuildContext context) {

    if(closePage) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: ElevatedButton(
              child: const Text("Enter Account"),
              onPressed: () => {
                Navigator.pop(
                  context, 
                  MaterialPageRoute(builder: (context) => UserHomePage(userToken: loginToken,)),
                )
              }
            ),
          ),
        ),
      );
    }
    else {
      return Scaffold(
        appBar: AppBar(title: const Text("Login")),
        body: Stack(
          children: [
            WebViewWidget(controller: controller,),
            if(loadingPer < 100) 
              LinearProgressIndicator(value: loadingPer/100.0,),
          ],
        ),
      );
    }
  }
}