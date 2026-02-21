import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voiceapp/providers/auth_provider.dart';
import 'package:voiceapp/providers/feed_provider.dart';
import 'package:voiceapp/providers/profile_provider.dart';
import 'package:voiceapp/screens/main_screen.dart';
import 'package:voiceapp/screens/splash_screen.dart';
import 'package:voiceapp/screens/login_screen.dart';
import 'package:voiceapp/screens/view_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sonar',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          fontFamily: 'Jakarta',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          fontFamily: 'Jakarta',
          scaffoldBackgroundColor: Color(0xFF121212),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF1F1F1F),
            foregroundColor: Colors.white,
          ),
        ),
        themeMode: ThemeMode.dark,
        navigatorKey: navigatorKey,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/main': (context) => MainScreen(),
          '/login': (context) => const LoginScreen(),
          '/view': (context) => const ViewScreen(),
        },
      ),
    );
  }
}
