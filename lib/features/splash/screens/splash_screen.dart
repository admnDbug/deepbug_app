import 'package:flutter/material.dart';
import '../../auth/screens/login_screen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  Future<void> _initAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _startAnimation = true;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutQuart,
              width: _startAnimation ? 160.0 : 0.0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _startAnimation ? 1.0 : 0.0,
                child: const Text(
                  'Deep Bug',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.bug_report, size: 50, color: Color(0xFFCCFF00)),
          ],
        ),
      ),
    );
  }
}