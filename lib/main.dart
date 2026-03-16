import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:voiceapp/firebase_options.dart';
import 'package:voiceapp/providers/auth_provider.dart';
import 'package:voiceapp/providers/deep_link_provider.dart';
import 'package:voiceapp/providers/feed_provider.dart';
import 'package:voiceapp/providers/location_provider.dart';
import 'package:voiceapp/providers/profile_provider.dart';
import 'package:voiceapp/services/deep_link_service.dart';
import 'package:voiceapp/screens/main_screen.dart';
import 'package:voiceapp/screens/splash_screen.dart';
import 'package:voiceapp/screens/login_screen.dart';
import 'package:voiceapp/screens/register_screen.dart';
import 'package:voiceapp/screens/view_screen.dart';
import 'package:voiceapp/screens/profile_screen.dart';
import 'package:voiceapp/services/auth_service.dart';
import 'package:voiceapp/services/logger.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.high,
    priority: Priority.high,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title,
    message.notification?.body,
    const NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    ),
  );
}

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://a87d7743207c746e8a120558e4e656ec@o4510947266461696.ingest.de.sentry.io/4510947269541968'; // replace with your DSN
      options.tracesSampleRate = 1.0;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();

      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }

        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        const AndroidInitializationSettings androidSettings =
            AndroidInitializationSettings('@mipmap/ic_launcher');

        const DarwinInitializationSettings iosSettings =
            DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
        await flutterLocalNotificationsPlugin.initialize(
          const InitializationSettings(
            android: androidSettings,
            iOS: iosSettings,
          ),
        );

        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
        );
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);

        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (e, stack) {
        Sentry.captureException(e, stackTrace: stack);
      }

      runApp(MyApp());
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupFCM();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = navigatorKey.currentContext!.read<DeepLinkProvider>();
      DeepLinkService(provider).init();
    });
  }

  Future<void> _sendFcmToken(String token) async {
    try {
      final authService = AuthService();
      final savedToken = await authService.getSavedToken();
      if (savedToken != null) {
        await authService.saveFcmToken(token);
        AppLogger.info('Token saved to db');
      } else {
        AppLogger.info('Token saved locally');
        await authService.storeFcmTokenLocally(token);
      }
    } catch (e) {
      AppLogger.error('Failed to send FCM token', exception: e);
    }
  }

  Future<void> _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.info('User granted permission');
      Sentry.captureMessage('permission check');
    }

    if (Platform.isIOS) {
      String? apnsToken;
      for (int i = 0; i < 10; i++) {
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) break;
        await Future.delayed(const Duration(seconds: 1)); // actually waits now
      }

      if (apnsToken == null) {
        Sentry.captureMessage('APNS token null after 10 retries');
        return;
      }

      Sentry.captureMessage('APNS token received successfully');
      AppLogger.debug('APNS token', data: apnsToken);
    }

    String? token = await messaging.getToken();
    AppLogger.debug('FCM token', data: token);
    if (token != null) await _sendFcmToken(token);

    messaging.onTokenRefresh.listen((newToken) {
      _sendFcmToken(newToken);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null && Platform.isAndroid) _showNotification(message);
      AppLogger.info('Foreground message', data: message.notification?.title);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('Notification tapped', data: message.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => DeepLinkProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
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
          '/register': (context) => const RegisterScreen(),
          '/view': (context) => const ViewScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/profile') {
            final userId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => ProfileScreen(userId: userId),
              settings: settings,
            );
          }
          return null;
        },
      ),
    );
  }
}
