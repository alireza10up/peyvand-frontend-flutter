import 'package:flutter/material.dart';
import 'package:peyvand/features/auth/presentation/screens/auth_screen.dart';
import 'package:peyvand/features/home/presentation/screens/home_screen.dart';
import 'package:peyvand/features/auth/data/services/auth_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:peyvand/features/posts/presentation/screens/create_edit_post_screen.dart';

import 'features/main/presentation/screens/main_tab_screen.dart';
import 'features/posts/presentation/screens/user_posts_screen.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return MaterialApp(
      title: 'اپلیکیشن پیوند',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Vazir',
        primarySwatch: Colors.blue,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 10.0,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
          ),
        ),
      ),
      home: FutureBuilder<bool>(
        future: authService.isAuthenticated,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            if (snapshot.hasData && snapshot.data == true) {
              return const MainTabScreen();
            } else {
              return const AuthScreen();
            }
          }
        },
      ),
      routes: {
        MainTabScreen.routeName: (context) => const MainTabScreen(),
        AuthScreen.routeName: (context) => const AuthScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        UserPostsScreen.routeName: (context) => const UserPostsScreen(),
        CreateEditPostScreen.routeName: (context) => const CreateEditPostScreen(),
      },
    );
  }
}
