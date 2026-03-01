import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:voiceapp/assets/constants.dart';
import 'package:voiceapp/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _apiError;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignUp() async {
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

      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.loginGoogle(idToken);

      if (!mounted) return;
      if (success) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Google sign-up failed')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in error: $e')),
      );
    }
  }

  Future<void> _handleRegister() async {
    setState(() => _apiError = null);
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      setState(() => _apiError = authProvider.error ?? 'Registration failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset + 24),
              child: Column(
                children: [
                  _RegisterBackButton(),
                  const SizedBox(height: 40),
                  const _RegisterHeader(),
                  const SizedBox(height: 40),
                  _GoogleButton(onPressed: _handleGoogleSignUp),
                  const SizedBox(height: 24),
                  const _Divider(),
                  const SizedBox(height: 24),
                  _FormField(
                    controller: _usernameController,
                    label: 'USERNAME',
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter a username';
                      if (v.trim().contains('@')) return 'Username cannot contain @';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    controller: _emailController,
                    label: 'EMAIL',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter an email';
                      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!emailRegex.hasMatch(v.trim())) return 'Please enter a valid email address';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _PasswordFormField(
                    controller: _passwordController,
                    label: 'PASSWORD',
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter a password';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _PasswordFormField(
                    controller: _confirmPasswordController,
                    label: 'CONFIRM PASSWORD',
                    validator: (v) {
                      if (v != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  if (_apiError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        _apiError!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                    ),
                  ],
                  const SizedBox(height: 34),
                  _RegisterButton(onPressed: _handleRegister),
                  const SizedBox(height: 24),
                  const _LoginLink(),
                  const SizedBox(height: 32),
                  const _Footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterBackButton extends StatelessWidget {
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
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const Spacer(),
        const Text(
          'Sign Up',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        const SizedBox(width: 40),
      ],
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _LogoCircle(),
        SizedBox(height: 24),
        Text(
          'Create your account',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Text(
          'Join Sonar and share your voice\nthrough short audio clips.',
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
        border: Border.all(color: Constants.primaryColor.withValues(alpha: 0.5), width: 2),
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

InputDecoration _fieldDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.05),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1),
    ),
  );
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final String? Function(String?) validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _fieldDecoration(label),
    );
  }
}

class _PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;

  const _PasswordFormField({
    required this.controller,
    required this.label,
    required this.validator,
  });

  @override
  State<_PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<_PasswordFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      decoration: _fieldDecoration(widget.label).copyWith(
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscureText = !_obscureText),
          child: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.white54,
          ),
        ),
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RegisterButton({required this.onPressed});

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
                    'Create Account',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        );
      },
    );
  }
}

class _LoginLink extends StatelessWidget {
  const _LoginLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text(
            'Log in',
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
