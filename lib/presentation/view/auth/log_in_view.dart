import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memecloud/data/models/auth/sign_in_request.dart';
import 'package:memecloud/domain/usecases/auth/sign_in.dart';
import 'package:memecloud/service_locator.dart';

class LogInView extends StatefulWidget {
  const LogInView({super.key});

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(),
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
        ),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Đăng Nhập',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              TextButton(
                child: const Text(
                  'Quên mật khẩu?',
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () async {},
              ),
              ElevatedButton(
                onPressed: () async {
                  var result = await serviceLocator<SignInUseCase>().call(
                    SignInRequest(
                      email: emailController.text.toString(),
                      password: passwordController.text.toString(),
                    ),
                  );
                  result.fold(
                    (l) {
                      // Handle error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đăng nhập thất bại: ${l.message}')),
                      );
                    },
                    (r) {
                      context.go('/home');
                    },
                  );
                },
                child: const Text(
                  'Đăng nhập',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
