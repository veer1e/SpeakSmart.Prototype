import 'package:flutter/material.dart';


class _P {
  static const bgTop  = Color(0xFFCDE8F5);
  static const bgBottom = Color(0xFFADD8EC);
  static const navy   = Color(0xFF1B3245);
}

class LoadingScreen extends StatefulWidget {
  final WidgetBuilder nextPageBuilder;
  final Duration      delay;

  const LoadingScreen({
    super.key,
    required this.nextPageBuilder,
    this.delay = const Duration(seconds: 2),
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _fade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(widget.delay);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:        (_, __, ___) => widget.nextPageBuilder(context),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin:  Alignment.topLeft,
            end:    Alignment.bottomRight,
            colors: [_P.bgTop, _P.bgBottom],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                Image.asset(
                  'assets/images/logo.png',
                  width:  120,
                  height: 120,
                ),
                const SizedBox(height: 20),
                Text(
                  'SpeakSmart',
                  style: TextStyle(
                    fontSize:      28,
                    fontWeight:    FontWeight.w900,
                    color:         _P.navy,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width:  28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color:       _P.navy.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}