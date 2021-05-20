import 'package:fire_chat/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fire_chat/components/rounded_button.dart';
import 'package:fire_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'register';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  bool showSpinner = false;
  TextEditingController textEditingController;

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

  bool validateStructure(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
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
                  controller: textEditingController,
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
                color: Colors.blueAccent,
                text: 'Register',
                onTap: () async {
                  try {
                    if (password.length < 6 || password.length > 15) {
                      _showMyDialog(
                        title: 'INVALID PASSWORD',
                        children: [
                          Text(
                            'Password must be of 6 to 15 characters',
                          ),
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    } else if (!validateStructure(password)) {
                      _showMyDialog(
                        title: 'INVALID PASSWORD',
                        children: [
                          Text(
                            'Password must contain'
                                '- an uppercase letter'
                                '- a lowercase letter'
                                '- a number'
                                '- a special character',
                          ),
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    } else {
                      setState(() {
                        showSpinner = true;
                      });
                      UserCredential newUser;
                      try {
                        newUser = await _auth.createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'email-already-in-use')
                          setState(() {
                            showSpinner = false;
                          });
                        _showMyDialog(
                          children: [
                            Text('Try another Email'),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            )
                          ],
                          title: 'Email already in use',
                        );
                      }
                      User user = _auth.currentUser;
                      user.sendEmailVerification();
                      if (newUser != null) {
                        if (!user.emailVerified) {
                          setState(() {
                            showSpinner = false;
                            _showMyDialog(
                              title: 'VERIFICATION REQUIRED',
                              children: [
                                Text('Verify your Email to Login'),
                                Text('An email has been sent'),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, LoginScreen.id);
                                  },
                                  child: Text('verified'),
                                )
                              ],
                            );
                          });
                        }
                        setState(() {
                          showSpinner = false;
                        });
                      }
                    }
                  } catch (e) {
                    print(e);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
