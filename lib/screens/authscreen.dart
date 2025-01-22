import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;

  showLoginErrorMessage(error) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Login failed.',
            style: TextStyle(
              color: Color(0xff181F39),
              fontFamily: 'VarelaRound',
            ),
          ),
          content: const SizedBox(
            child: Text(
              'Credentials are incorrect.',
              style: TextStyle(
                color: Color(0xff181F39),
                fontFamily: 'VarelaRound',
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Color(0xff181F39),
                ),
              ),
              onPressed: () {
                emailController.clear();
                passwordController.clear();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Ok',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'VarelaRound',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  login() async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty && password.isEmpty) {
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      showLoginErrorMessage(e);
    }
  }

  signup() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty && password.isEmpty) {
      return;
    }

    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              cursorColor: const Color(0xff181F39),
              style: const TextStyle(
                fontFamily: 'VarelaRound',
              ),
              controller: emailController,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.email,
                  color: Color(0xff181F39),
                ),
                hintText: 'Email ID',
                hintStyle: TextStyle(
                  color: Color(0xff181F39),
                  fontFamily: 'VarelaRound',
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: _obscureText,
              cursorColor: const Color(0xff181F39),
              style: const TextStyle(fontFamily: 'VarelaRound'),
              controller: passwordController,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.lock,
                  color: Color(0xff181F39),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
                hintText: 'Password',
                hintStyle: const TextStyle(
                  color: Color(0xff181F39),
                  fontFamily: 'VarelaRound',
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Color(0xff181F39),
                ),
              ),
              onPressed: login,
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'VarelaRound',
                ),
              ),
            ),
            TextButton(
              onPressed: signup,
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  color: Color(0xff181F39),
                  fontFamily: 'VarelaRound',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
