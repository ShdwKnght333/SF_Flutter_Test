import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sf_auth_test/Classes/auth_token.dart';
import 'package:sf_auth_test/Classes/helpers.dart';
import 'package:sf_auth_test/Proxy/custom_proxy.dart';
import 'package:sf_auth_test/loggedin_page.dart';
import 'login_view.dart';

void main() async {
  if(!kReleaseMode) {
    final proxy = CustomProxy(ipAddress: '10.100.35.134', port: 8866);
    // proxy.enable();
  }
  
  runApp(const SFAuthTest());
}

class SFAuthTest extends StatelessWidget {
  const SFAuthTest({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SF Auth Test Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 13, 142, 218)),
        useMaterial3: true,
      ),
      home: const SFLogin(),
    );
  }
}

class SFLogin extends StatefulWidget {
  const SFLogin({super.key});

  @override
  State<SFLogin> createState() => _SFLoginState();
}

class _SFLoginState extends State<SFLogin> {
  late AuthToken existingToken;
  bool showWebPage = true;
  bool loginDisabled = true;
  String buttonText = "Login";

  @override
  void initState() {
    super.initState();
    checkForStoredToken();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage("assets/SFimage.png"),
                width: 250,
                height: 250,                
              ),
              ElevatedButton(
                onPressed: loginDisabled ? null : () => {
                  if(showWebPage) {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const LoginWebPage()),
                      )
                  }
                  else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserHomePage(userToken: existingToken,)),
                    ),
                  }
                },
                child: Text(buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkForStoredToken() async {
    AuthToken storedToken = await getTokenFromStorage();
    setState(() {
      if(!storedToken.isFake()) {
        existingToken = storedToken;
        showWebPage = false;
        buttonText = "Enter Account";
      }
      loginDisabled = false;
    });
  } 
}