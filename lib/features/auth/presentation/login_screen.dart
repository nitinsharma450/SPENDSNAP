import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/snap_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLogin = true; // Add toggle state

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("SpendSnap",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(isLogin ? "Manage your scratch like a pro." : "Create your account.",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 48),
            SnapTextField(hint: "Email", icon: Icons.email_outlined, controller: emailController),
            const SizedBox(height: 16),
            SnapTextField(hint: "Password", icon: Icons.lock_outline, controller: passwordController, isPassword: true),
            const SizedBox(height: 32),
            auth.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: () async {
                // Toggle logic between login and signup
                final error = isLogin
                    ? await auth.login(emailController.text, passwordController.text)
                    : await auth.signUp(emailController.text, passwordController.text);

                if (error != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                }
              },
              child: Text(isLogin ? "Login" : "Sign Up"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin; // Toggle the view
                });
              },
              child: Text(isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}