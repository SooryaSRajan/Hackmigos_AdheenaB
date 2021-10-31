import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:automated_ambualnce/ui/home.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);
  static const String id = 'Splash_screen';

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 3000,
      splash: SplashObject(),
      nextScreen: Home(
        flag: 0,
      ),
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Color(0xFF1b3b56),
    );
  }
}

class SplashObject extends StatelessWidget {
  const SplashObject({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          child: Icon(Icons.local_hospital_outlined,
              color: Color(0xFFD9655B), size: 35),
        ),
        SizedBox(height: 10),
        Center(
          child: Container(
              child: Text(
                'Mediculus',
                style: TextStyle(
                    fontFamily: 'Comforta',
                    fontSize: 30,
                    color: Color(0xFFD9655B)),
              )),
        )
      ],
    );
  }
}
