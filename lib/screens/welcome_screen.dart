import 'package:fire_chat/screens/login_screen.dart';
import 'package:fire_chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:fire_chat/components/rounded_button.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class WelcomeScreen extends StatefulWidget {
  static String id='welcome';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}
//********Mixin are Add on classes , we can use more than one mixin with a class*************
class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin{
  AnimationController controller;
  Animation animation;
  @override

  void initState() {
    super.initState();
    controller=AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );


    // ******DO NOT USE UPPER BOUND MORE THAN 1 WHILE USING CURVED ANIMATIONS,******
    animation=ColorTween(begin: Colors.blueGrey,end: Colors.white).animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.jpg'),
                    height: 60,
                  ),
                ),
                AnimatedTextKit(
                    animatedTexts:[TypewriterAnimatedText('Flash Chat',textStyle: TextStyle(
                      fontSize: 45.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                      speed: Duration(milliseconds: 200),

                    )
                    ]
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(color:Colors.lightBlueAccent,
              onTap: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
              text: 'Log In',),
            RoundedButton(color: Colors.blueAccent,
              text: 'Register',
              onTap: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },)
          ],
        ),
      ),
    );
  }
}


