import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryColor = Color(0xFFD4E157);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _LogoBox(),
                SizedBox(height: 24),
                _TitleText(),
              ],
            ),
          ),

        
          const _ProgressBar(),
          const _AudioBadge(),
        ],
      ),
    );
  }
}

class _LogoBox extends StatelessWidget {
  const _LogoBox();

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD4E157);

    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 24,
            spreadRadius: 16,
          ),
        ],
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white10),
      ),
      child: const Center(
        child: Icon(
          Icons.graphic_eq,
          color: primaryColor,
          size: 48,
        ),
      ),
    );
  }
}

class _TitleText extends StatelessWidget {
  const _TitleText();

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD4E157);

    return Column(
      children: const [
        Text(
          'Sonar',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Hear the world.',
          style: TextStyle(
            color: Color(0xB2D4E157),
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 180,
      left: 40,
      right: 40,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const LinearProgressIndicator(
            value: 0.5,
            backgroundColor: Colors.white10,
            color: Color(0xFFD4E157),
            minHeight: 6,
          ),
        ),
      ),
    );
  }
}

class _AudioBadge extends StatelessWidget {
  const _AudioBadge();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 80,
      right: 80,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white10),
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 70, 69, 69).withOpacity(0.05),
              const Color.fromARGB(255, 52, 52, 52).withOpacity(0.2),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(
                Icons.graphic_eq,
                color: Color(0xFFD4E157),
                size: 38,
              ),
              Text(
                'AUDIO FIRST SOCIAL',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.25,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
