import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (isLogin) {
        // Вхід
        print('Login with $email and $password');
      } else {
        // Реєстрація
        print('Register with $email and $password');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Увійти' : 'Реєстрація'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => email = value!,
                validator: (value) =>
                    value!.contains('@') ? null : 'Невалідний email',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
                onSaved: (value) => password = value!,
                validator: (value) =>
                    value!.length >= 6 ? null : 'Мін. 6 символів',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isLogin ? 'Увійти' : 'Зареєструватися'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(isLogin
                    ? 'Немає акаунту? Зареєструватися'
                    : 'Вже маєш акаунт? Увійти'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
