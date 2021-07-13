import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_tracker/ui/screens/main.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

GoogleSignIn _googleSignIn = GoogleSignIn(
  // clientId: '192633702539-43vof2btppdn077h80k06e3mu72ut4lc.apps.googleusercontent.com',
  scopes:[
    'email',
    'profile'
  ]
);

class SignInGoogleScreen extends StatefulWidget {
  @override
  _SignInGoogleScreenState createState() => _SignInGoogleScreenState();
}

class _SignInGoogleScreenState extends State<SignInGoogleScreen> {

  GoogleSignInAccount _currentUser;
  String idToken;
  String accessToken;
  String serverAuthCode;

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
        // isLoggedIn = true;
        // print('huy');
        // print(isLoggedIn);
      });
      // if (_currentUser != null) {
      //   _handleGetContact(_currentUser);
      // }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    GoogleSignInAccount user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          const Text("Signed in successfully."),
          // Text("idToken: $idToken"),
          Text("accessToken: $accessToken"),
          Text("serverAuthCode: $serverAuthCode"),
          ElevatedButton(
            child: const Text('SIGN OUT'),
            onPressed: _handleSignOut,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in."),
          ElevatedButton(
            child: const Text('SIGN IN'),
            onPressed: handleSignIn,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google Sign In'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
  
  Future handleSignIn() async {
    try{
      // await _googleSignIn.signIn();
      final result = await _googleSignIn.signIn();
      final ggAuth = await result.authentication;
      //
      // final token = ggAuth.accessToken;
      // final data = await http.get(
      //     Uri.parse("https://people.googleapis.com/v1/people/me?personFields=emailAddresses"),
      //     headers: {
      //       "Accept": "application/json",
      //       "Authorization": "Bearer $token"
      //     }
      //     );
      // print(data.body);
      idToken = ggAuth.idToken;
      accessToken = ggAuth.accessToken;
      serverAuthCode = ggAuth.serverAuthCode;




    } catch(error) {
      print(error);
    }
  }
}