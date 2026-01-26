import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Providers
import 'providers/auth_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_home_screen.dart';

/// Глобальное переопределение HttpClient для принятия самоподписанных сертификатов
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Загружаем .env если он существует (для демо-режима не обязательно)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // .env файл не найден - это нормально для демо-режима
    print('Note: .env file not found, using demo mode');
  }
  // Применяем глобальное переопределение для HttpClient
  HttpOverrides.global = MyHttpOverrides();

  // Инициализация уведомлений и фоновых задач
  await _initNotifications();
  await _requestNotificationPermissions();
  Workmanager().initialize(_callbackDispatcher);
  Workmanager().registerPeriodicTask(
    'notify_rentals',
    'notify_rentals',
    frequency: const Duration(days: 1),
  );

  // Настройка Dio и CookieJar
  final dio = Dio();
  final directory = await getApplicationDocumentsDirectory();
  final cookieJar = PersistCookieJar(
    storage: FileStorage('${directory.path}/.cookies/'),
  );
  dio.interceptors.add(CookieManager(cookieJar));

  // Переопределяем HttpClient для Dio, чтобы игнорировать ошибки SSL
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    },
  );

  // Провайдер аутентификации
  final authProvider = AuthProvider(dio, cookieJar);

  // Интерсептор для добавления Access-token
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = authProvider.token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (err, handler) async {
        if (err.response?.statusCode == 401 &&
            err.response?.statusCode == 403 &&
            !err.requestOptions.extra.containsKey('retry')) {
          try {
            await authProvider.silentAutoLogin();
            err.requestOptions.extra['retry'] = true;
            final clonedReq = await dio.fetch(err.requestOptions);
            handler.resolve(clonedReq);
          } catch (_) {
            handler.next(err);
          }
        } else {
          handler.next(err);
        }
      },
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<Dio>.value(value: dio),
        Provider<CookieJar>.value(value: cookieJar),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        // Сервисы временно отключены для демо-режима
        // Provider<ProductService>(create: (_) => ProductService(dio)),
        // Provider<UserService>(create: (_) => UserService(dio)),
        // Provider<CategoryService>(create: (_) => CategoryService(dio)),
        // Provider<OrderService>(create: (_) => OrderService(dio)),
      ],
      child: const MyApp(),
    ),
  );
}

final FlutterLocalNotificationsPlugin _notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _initNotifications() async {
  const androidSettings = AndroidInitializationSettings('app_icon');
  const iosSettings = DarwinInitializationSettings();
  const settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await _notificationsPlugin.initialize(settings);
}

Future<void> _requestNotificationPermissions() async {
  if (!await Permission.notification.isGranted) {
    await Permission.notification.request();
  }
}

void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'notify_rentals') {
      // TODO: logic for notifications
      return Future.value(true);
    }
    return Future.value(false);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qamqor Clinic',
      theme: ThemeData(
        primaryColor: const Color(0xFF3498DB),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF3498DB),
          secondary: Color(0xFF2C3E50),
        ),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/splash':
            page = const SplashScreen();
            break;
          case '/auth':
            page = const AuthScreen();
            break;
          case '/main':
            page = const MainHomeScreen();
            break;
          default:
            page = const SplashScreen();
        }
        return MaterialPageRoute(builder: (_) => page);
      },
    );
  }
}

