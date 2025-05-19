import 'package:flutter/material.dart';
import 'package:flutter_application_3/database_helper.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLogin) {
        // Логін
        final user = await DatabaseHelper.instance.getUser(email, password);
        if (user != null) {
          // Перехід до головного екрану після успішного логіну
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainScreen()),
          );
        } else {
          // Якщо користувача немає в базі
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid credentials')),
          );
        }
      } else {
        // Реєстрація
        // Додаємо нового користувача до бази
        await DatabaseHelper.instance.insertUser(email, password);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created. Please login.')),
        );
        setState(() {
          _isLogin = true;  // Після реєстрації перемикаємо на екран логіну
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(_isLogin ? 'Login' : 'Register', style: TextStyle(fontSize: 24)),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) =>
                        value != null && value.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(_isLogin ? 'Login' : 'Register'),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => _isLogin = !_isLogin),
                    child: Text(_isLogin
                        ? 'Don\'t have an account? Register'
                        : 'Already have an account? Login'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
