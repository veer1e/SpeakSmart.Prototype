import 'package:flutter/material.dart';
import 'loading_screen.dart';
import 'signup_screen.dart';
import '../shell/presentation/shell_screen.dart';

// ─── Palette ───────────────────────────────────────────────────────────────────
class _P {
  static const bgTop     = Color(0xFFCDE8F5);
  static const bgBottom  = Color(0xFFADD8EC);
  static const navy      = Color(0xFF1B3245);
  static const cardWhite = Color(0xBBFFFFFF);
  static const cardBorder= Color(0xCCFFFFFF);
  static const textDark  = Color(0xFF1B3245);
  static const textMuted = Color(0xFF5A7A8A);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // ── Focus nodes for tab-key / next-field navigation ──────────────────────
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading       = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onSignIn() {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields.'),
          backgroundColor: _P.navy,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LoadingScreen(
            nextPageBuilder: (_) => const ShellScreen(),
            delay: const Duration(milliseconds: 1200),
          ),
        ),
      );
    });
  }

  void _goToSignUp() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:        (_, __, ___) => const SignupScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin:  Alignment.topLeft,
            end:    Alignment.bottomRight,
            colors: [_P.bgTop, _P.bgBottom],
          ),
        ),
        child: Stack(
          children: [
            const _BlobDecoration(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App name
                    Text(
                      'SpeakSmart',
                      style: TextStyle(
                        fontSize:      20,
                        fontWeight:    FontWeight.w900,
                        color:         _P.navy,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Welcome text
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Welcome to',
                            style: TextStyle(
                              fontSize:   22,
                              fontWeight: FontWeight.w600,
                              color:      _P.navy,
                            ),
                          ),
                          Text(
                            'SpeakSmart!',
                            style: TextStyle(
                              fontSize:      28,
                              fontWeight:    FontWeight.w900,
                              color:         _P.navy,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Glass card
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Text(
                              'Sign-in',
                              style: TextStyle(
                                fontSize:   22,
                                fontWeight: FontWeight.w800,
                                color:      _P.navy,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          _FieldLabel('Username:'),
                          const SizedBox(height: 6),
                          _AuthField(
                            controller:      _usernameCtrl,
                            hint:            'Enter your username',
                            focusNode:       _usernameFocus,
                            textInputAction: TextInputAction.next,
                            onSubmitted:     (_) => FocusScope.of(context)
                                .requestFocus(_passwordFocus),
                          ),
                          const SizedBox(height: 16),

                          _FieldLabel('Password:'),
                          const SizedBox(height: 6),
                          _AuthField(
                            controller:      _passwordCtrl,
                            hint:            'Enter your password',
                            focusNode:       _passwordFocus,
                            obscure:         _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted:     (_) => _onSignIn(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _P.textMuted,
                                size:  20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: 28),

                          
                          Center(
                            child: SizedBox(
                              width:  200,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _P.navy,
                                  foregroundColor: Colors.white,
                                  elevation:   4,
                                  shadowColor: _P.navy.withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                                onPressed: _isLoading ? null : _onSignIn,
                                child: _isLoading
                                    ? const SizedBox(
                                        width:  22,
                                        height: 22,
                                        child:  CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color:       Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'SIGN-IN',
                                        style: TextStyle(
                                          fontSize:      15,
                                          fontWeight:    FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Sign-up link
                    Center(
                      child: GestureDetector(
                        onTap: _goToSignUp,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 13, color: _P.textDark),
                            children: [
                              const TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text:  'Click here to sign-up',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color:      _P.navy,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color:        _P.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border:       Border.all(color: _P.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize:   13,
        fontWeight: FontWeight.w600,
        color:      _P.textDark,
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController  controller;
  final String                 hint;
  final FocusNode?             focusNode;
  final TextInputAction        textInputAction;
  final ValueChanged<String>?  onSubmitted;
  final bool                   obscure;
  final Widget?                suffixIcon;

  const _AuthField({
    required this.controller,
    required this.hint,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.obscure    = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:      controller,
      focusNode:       focusNode,
      obscureText:     obscure,
      textInputAction: textInputAction,
      onSubmitted:     onSubmitted,
      style:           TextStyle(color: _P.textDark, fontSize: 14),
      decoration: InputDecoration(
        hintText:   hint,
        hintStyle:  TextStyle(color: _P.textMuted, fontSize: 13),
        suffixIcon: suffixIcon,
        filled:     true,
        fillColor:  Colors.white.withOpacity(0.88),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   BorderSide(color: Colors.white.withOpacity(0.6), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   BorderSide(color: _P.navy, width: 1.5),
        ),
      ),
    );
  }
}

class _BlobDecoration extends StatelessWidget {
  const _BlobDecoration();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(top: -60,  right: -40, child: _blob(160, _P.navy.withOpacity(0.18))),
        Positioned(top: size.height * 0.25, left: -50, child: _blob(130, _P.navy.withOpacity(0.12))),
        Positioned(bottom: size.height * 0.1, right: -30, child: _blob(100, _P.navy.withOpacity(0.10))),
        Positioned(bottom: -40, left: size.width * 0.2, child: _blob(140, _P.navy.withOpacity(0.15))),
      ],
    );
  }

  Widget _blob(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}