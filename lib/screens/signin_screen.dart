import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart' as fa;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

import 'package:gssa_2/screens/home_screen.dart';
import 'package:gssa_2/screens/sigup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _shape1Controller;
  late AnimationController _shape2Controller;
  late AnimationController _shape3Controller;

  @override
  void initState() {
    super.initState();

    _shape1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _shape2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _shape3Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _shape1Controller.repeat(reverse: true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _shape2Controller.repeat(reverse: true);
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _shape3Controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _shape1Controller.dispose();
    _shape2Controller.dispose();
    _shape3Controller.dispose();
    super.dispose();
  }

  void _trySignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${_usernameController.text}!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const StudentGradeSystemHomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: Stack(
          children: [
            _buildAnimatedShape(
              controller: _shape1Controller,
              size: 80,
              top: MediaQuery.of(context).size.height * 0.2,
              left: MediaQuery.of(context).size.width * 0.1,
              delay: 0,
            ),
            _buildAnimatedShape(
              controller: _shape2Controller,
              size: 60,
              top: MediaQuery.of(context).size.height * 0.6,
              right: MediaQuery.of(context).size.width * 0.1,
              delay: 2,
            ),
            _buildAnimatedShape(
              controller: _shape3Controller,
              size: 100,
              bottom: MediaQuery.of(context).size.height * 0.2,
              left: MediaQuery.of(context).size.width * 0.2,
              delay: 4,
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25.0),
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 800),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.all(40),
                    constraints: const BoxConstraints(maxWidth: 440),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLogoSection(),
                          const SizedBox(height: 30),
                          _buildUsernameInput(),
                          const SizedBox(height: 20),
                          _buildEmailInput(),
                          const SizedBox(height: 20),
                          _buildPasswordInput(),
                          const SizedBox(height: 30),
                          _buildSignInButton(),
                          const SizedBox(height: 30),
                          _buildDivider(),
                          const SizedBox(height: 30),
                          _buildSocialButtons(),
                          const SizedBox(height: 30),
                          _buildSwitchLinks(),
                          const SizedBox(height: 10),
                          _buildForgotPasswordButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedShape({
    required AnimationController controller,
    required double size,
    double? top,
    double? bottom,
    double? left,
    double? right,
    int delay = 0,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final floatOffset = Tween<double>(
            begin: 0,
            end: -20,
          ).evaluate(controller);
          final rotationAngle = Tween<double>(
            begin: 0,
            end: math.pi * 2,
          ).evaluate(controller);
          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: Transform.rotate(
              angle: rotationAngle,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(size / 2),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _shape1Controller,
          builder: (context, child) {
            final pulseScale = Tween<double>(
              begin: 1,
              end: 1.05,
            ).evaluate(_shape1Controller);
            return Transform.scale(
              scale: pulseScale,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    '✦',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1a1a),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to your account',
          style: TextStyle(fontSize: 16, color: Color(0xFF6b7280)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUsernameInput() {
    return TextFormField(
      controller: _usernameController,
      decoration: const InputDecoration(
        labelText: 'Username',
        hintText: 'Enter your username',
        prefixIcon: Icon(fa.FontAwesomeIcons.user, size: 18),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your username';
        }
        return null;
      },
    );
  }

  Widget _buildEmailInput() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email Address',
        hintText: 'your.email@example.com',
        prefixIcon: Icon(fa.FontAwesomeIcons.envelope, size: 18),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email address';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordInput() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: '••••••••',
        prefixIcon: const Icon(fa.FontAwesomeIcons.lock, size: 18),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Widget _buildSignInButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _trySignIn,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 18),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 5,
        shadowColor: const Color(0xFF667eea).withOpacity(0.4),
      ),
      child:
          _isLoading
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
              : const Text('Sign In'),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFe5e7eb), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'or sign in with',
            style: TextStyle(color: Color(0xFF9ca3af), fontSize: 14),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFe5e7eb), thickness: 1)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Google Sign-in clicked!')),
              );
            },
            icon: FaIcon(
              fa.FontAwesomeIcons.google,
              size: 20,
              color: Colors.red.shade700,
            ),
            label: const Text('Google'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xFFe5e7eb), width: 2),
              foregroundColor: const Color(0xFF374151),
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Facebook Sign-in clicked!')),
              );
            },
            icon: FaIcon(
              fa.FontAwesomeIcons.facebook,
              size: 20,
              color: Colors.blue.shade800,
            ),
            label: const Text('Facebook'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xFFe5e7eb), width: 2),
              foregroundColor: const Color(0xFF374151),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchLinks() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignupScreen()),
        );
      },
      child: Text.rich(
        TextSpan(
          text: "Don't have an account? ",
          style: const TextStyle(color: Color(0xFF6b7280), fontSize: 14),
          children: [
            TextSpan(
              text: 'Sign up',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Forgot Password logic goes here!')),
        );
      },
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
