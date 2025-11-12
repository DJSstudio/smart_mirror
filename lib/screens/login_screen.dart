import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final AuthService _auth = AuthService();

  bool _loading = false;
  String? _error;

  void _doLogin() async {
    setState(() { _loading = true; _error = null; });

    final ok = await _auth.login(_userCtrl.text.trim(), _passCtrl.text.trim());

    setState(() => _loading = false);

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => _error = "Invalid username or password.");
    }
  }

  void _doRegister() async {
    setState(() { _loading = true; _error = null; });

    final ok = await _auth.register(_userCtrl.text.trim(), _passCtrl.text.trim());

    setState(() => _loading = false);

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => _error = "Registration failed. Username may already exist.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Login or Register', style: TextStyle(fontSize: 22)),
            TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'Username')),
            const SizedBox(height: 8),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _doLogin,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Login'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loading ? null : _doRegister,
              child: const Text('Register'),
            ),
          ]),
        ),
      ),
    );
  }
}
