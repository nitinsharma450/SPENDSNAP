import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/budget/providers/goal_provider.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/transactions/providers/transaction_provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart'; // 1. Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseDatabase.instance.setPersistenceEnabled(true);

  runApp(const SpendSnapApp());
}

class SpendSnapApp extends StatelessWidget {
  const SpendSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Update TransactionProvider
        ChangeNotifierProxyProvider<AuthProvider, TransactionProvider?>(
          create: (_) => null,
          update: (_, auth, previous) {
            if (auth.user == null) return null;
            return TransactionProvider(auth.user!.uid);
          },
        ),
        // Add this Block for GoalProvider!
        ChangeNotifierProxyProvider<AuthProvider, GoalProvider?>(
          create: (_) => null,
          update: (_, auth, previous) {
            if (auth.user == null) return null;
            return GoalProvider(auth.user!.uid);
          },
        ),
      ],
      child: MaterialApp(
        title: 'SpendSnap',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.user != null) {
              return const DashboardScreen(); // Show Dashboard!
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
