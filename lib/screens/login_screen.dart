import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:voiceapp/assets/constants.dart';
import 'package:voiceapp/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleLogin() async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: '436648307274-tdlhrrv14kdvt59e2purgdjvm0lji1et.apps.googleusercontent.com',
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get Google ID token')),
        );
        return;
      }

      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.loginGoogle(idToken);

      if (!mounted) return;
      if (success) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Google login failed')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in error: $e')),
      );
    }
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a username')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginAnonymous(username);

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const _BackButton(),
                const SizedBox(height: 40),
                const _Header(),
                const SizedBox(height: 40),
                _GoogleButton(onPressed: _handleGoogleLogin),
                const SizedBox(height: 24),
                const _Divider(),
                const SizedBox(height: 24),
                _EmailField(controller: _usernameController),
                const SizedBox(height: 16),
                // _PasswordField(controller: _passwordController),
                const SizedBox(height: 34),
                _LoginButton(onPressed: _handleLogin),
                const SizedBox(height: 24),
                const _SignUpLink(),
                const SizedBox(height: 32),
                const _Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/main', arguments: {}),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const Spacer(),
        const Text(
          'Login',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        SizedBox(width: 40),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _LogoCircle(),
        SizedBox(height: 24),
        Text(
          'Welcome to Sonar',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Text(
          'Hear what\'s happening now through\nshort audio clips.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}

class _LogoCircle extends StatelessWidget {
  const _LogoCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Constants.primaryColor.withOpacity(0.5), width: 2),
      ),
      child: const Center(
        child: Icon(Icons.graphic_eq, size: 48, color: Constants.primaryColor),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GoogleButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/google.png', width: 24, height: 24),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.white10)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('or', style: TextStyle(color: Colors.white54)),
        ),
        Expanded(child: Container(height: 1, color: Colors.white10)),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;

  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration('USERNAME OR EMAIL'),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const _PasswordField({required this.controller});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: 'PASSWORD',
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              child: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.white54,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Forgot password?',
          style: TextStyle(color: Constants.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: auth.isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primaryColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: auth.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Text(
                    'Login with Username',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        );
      },
    );
  }
}

class _SignUpLink extends StatelessWidget {
  const _SignUpLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Don\'t have an account? ',
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Sign up',
            style: TextStyle(color: Constants.primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'TERMS',
          style: TextStyle(color: Colors.white30, fontSize: 12, letterSpacing: 0.5),
        ),
        SizedBox(width: 24),
        Text(
          'PRIVACY',
          style: TextStyle(color: Colors.white30, fontSize: 12, letterSpacing: 0.5),
        ),
        SizedBox(width: 24),
        Text(
          'HELP',
          style: TextStyle(color: Colors.white30, fontSize: 12, letterSpacing: 0.5),
        ),
      ],
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white.withOpacity(0.05),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  );
}
