import 'package:fire_chat/constants.dart';
import 'package:fire_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:fire_chat/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showSpinner = false;
  String email;

  String password;
  final _auth = FirebaseAuth.instance;
  User currentUser;

  Future<void> _showMyDialog(
      {@required List<Widget> children, @required String title}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(color: Colors.red),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: children,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/logo.jpg'),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration:
                kTextFieldDecoration.copyWith(hintText: 'Enter Your Email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter Your Password')),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                color: Colors.lightBlueAccent,
                onTap: () async {

                  try {
                    setState(() {
                      showSpinner = true;
                    });
                    final user = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    currentUser = _auth.currentUser;
                    if (!currentUser.emailVerified) {
                      setState(() {
                        showSpinner = false;
                        _showMyDialog(
                          title: 'VERIFICATION REQUIRED',
                          children: [
                            Text('Verify your Email to Login'),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('OK'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    currentUser.sendEmailVerification();
                                    Navigator.pop(context);
                                  },
                                  child: Text('Resend verification mail'),
                                ),
                              ],
                            )
                          ],
                        );
                        _auth.signOut();
                      });
                    } else {
                      if (user != null) {
                        Navigator.pushNamed(context, ChatScreen.id);
                        setState(() {
                          showSpinner = false;
                        });
                      }
                    }
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found') {
                      setState(() {
                        showSpinner = false;
                      });
                      _showMyDialog(children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'))
                      ], title: 'NO SUCH USER');
                    } else if (e.code == 'wrong-password') {
                      setState(() {
                        showSpinner = false;
                      });
                      _showMyDialog(children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'))
                      ], title: 'WRONG PASSWORD');
                    }
                  }
                },
                text: 'Log In',
              ),
              RoundedButton(
                onTap: () {
                  String currEmail;
                  _showMyDialog(children: [
                    TextField(
                      onChanged: (value) {
                        currEmail = value;
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter Your Email',
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.green, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.deepPurpleAccent, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _auth.sendPasswordResetEmail(email: currEmail);
                        Navigator.pop(context);
                      },
                      child: Text('Reset Password'),
                    )
                  ], title: 'PASSWORD RESET');
                },
                color: Colors.green,
                text: 'Forgot Password!',
              )
            ],
          ),
        ),
      ),
    );
  }
}
