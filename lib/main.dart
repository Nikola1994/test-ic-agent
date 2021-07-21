import 'package:agent_dart/agent/auth.dart';
import 'package:agent_dart/auth_client/webauth_provider.dart';
import 'package:agent_dart_example/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'init.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _count = 0;
  bool _loading = false;
  String _status = "";
  Identity? _identity;
  late Signup _signup;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // initSignup(); We moved that to later initialization of agent, because we need Delegation Identity instead of Anonymous Identity
    loading(true);
  }

  void initSignup() {
    _signup = AgentFactory.create(
      canisterId: "a64ux-piaaa-aaaae-aaara-cai",
      url: "https://boundary.ic0.app/", // For Android emulator, please use 10.0.2.2 as endpoint
      idl: idl,
      identity: _identity,
      debug: false
    ).hook(Signup());
  }

  void loading(bool state) {
    setState(() {
      _loading = state;
    });
  }

  void signup() async {
    initSignup();
    List arguments = [{
      'company' : "company",
      'education' : "Education",
      'display_name' : "Display name",
      'title' : "Title",
      'username' : "usernametest",
      'description' : "Description ...",
      'link' : "www.google.com",
      'location' : "location",
      'pubkey' : []
    }];
    print("Start");
    dynamic c = await _signup.signup(arguments);
    print(c);
    print("End");
    loading(false);
    setState(() {
    });
  }

  void authenticate() async {
    try {
      var authClient = WebAuthProvider(
          scheme: "identity",
          path: 'auth',
          authUri: Uri.parse('https://identity.ic0.app/#authorize'),
          useLocalPage: true);

      await authClient.login(
          // AuthClientLoginOptions()..canisterId = "rwlgt-iiaaa-aaaaa-aaaaa-cai"
          );
      var loginResult = await authClient.isAuthenticated();

      _identity = authClient.getIdentity();

      setState(() {
        _status = 'Got result: $loginResult';
      });
    } on PlatformException catch (e) {
      setState(() {
        _status = 'Got error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Dfinity flutter Dapp'),
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(_loading ? 'loading contract count' : '$_count'),
            Container(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () {
                  authenticate();
                },
                child: const Text("Click here to Login")),
            Container(
              height: 30,
            ),
            Text(_status.isEmpty ? "Please Login 👆" : _status),
            Container(
              height: 30,
            ),
            Text(_status.isEmpty ? "" : "Principal is ${_identity?.getPrincipal().toText()}"),
          ]),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: _identity != null
              ? () async {
                  signup();
                }
              : () {
                  _showDialog();
                },
        ),
      ),
    );
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: const Text("Please login first 🙇‍♂️"),
          content: const Text("Then try here again, "),
          actions: <Widget>[
            TextButton(
              child: const Text('Close me!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
