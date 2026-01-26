import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

// Providers
import 'providers/auth_provider.dart';

// Services - используем mock сервисы
import 'services/mock_product_service.dart';
import 'services/mock_category_service.dart';
import 'services/mock_order_service.dart';

// Screens
import 'screens/product_detail_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/payment_status_screen.dart';
import 'screens/main_home_screen.dart';
import 'screens/my_orders_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/support_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/about_screen.dart';
import 'screens/my_cart_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/moderator_home_screen.dart';
import 'screens/products_screen.dart';
import 'screens/add_product_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация уведомлений и фоновых задач
  await _initNotifications();
  await _requestNotificationPermissions();
  Workmanager().initialize(_callbackDispatcher);
  Workmanager().registerPeriodicTask(
    'notify_appointments',
    'notify_appointments',
    frequency: const Duration(days: 1),
  );

  // Провайдер аутентификации (использует mock сервис)
  final authProvider = AuthProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        Provider<MockProductService>(create: (_) => MockProductService()),
        Provider<MockCategoryService>(create: (_) => MockCategoryService()),
        Provider<MockOrderService>(create: (_) => MockOrderService()),
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
    if (task == 'notify_appointments') {
      // TODO: logic for appointment notifications
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
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2E7D32),
          secondary: Color(0xFF1B5E20),
          tertiary: Color(0xFF4CAF50),
        ),
        fontFamily: 'Montserrat',
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
          case '/products':
            page = const ProductsScreen();
            break;
          case '/add-product':
            page = const AddProductScreen();
            break;
          case '/my-cart':
            page = const MyCartScreen();
            break;
          case '/notifications':
            page = const NotificationsScreen();
            break;
          case '/reset-password':
            page = const ResetPasswordScreen();
            break;
          case '/admin-home':
            page = const AdminHomeScreen();
            break;
          case '/moderator-home':
            page = const ModeratorHomeScreen();
            break;
          case '/support':
            page = SupportScreen();
            break;
          case '/about':
            page = const AboutScreen();
            break;
          case '/product-detail':
            final id = settings.arguments as int;
            page = ProductDetailScreen(productId: id);
            break;
          case '/orders':
            page = const MyOrdersScreen();
            break;
          case '/payment':
            final args = settings.arguments as Map<String, dynamic>;
            page = PaymentScreen(
              orderId: args['orderId'] as int,
              orderTotal: args['orderTotal'] as double,
            );
            break;
          case '/payment-status':
            final pid = settings.arguments as int;
            page = PaymentStatusScreen(orderId: pid);
            break;
          default:
            page = const SplashScreen();
        }
        return CircularRevealRoute(page: page);
      },
    );
  }
}

class CircularRevealRoute extends PageRouteBuilder {
  final Widget page;
  CircularRevealRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ClipOval(
              clipper: CircleRevealClipper(
                fraction: animation.value,
                centerOffset: Offset(
                  MediaQuery.of(context).size.width / 2,
                  MediaQuery.of(context).size.height / 2,
                ),
              ),
              child: child,
            );
          },
        );
}

class CircleRevealClipper extends CustomClipper<Rect> {
  final double fraction;
  final Offset centerOffset;

  CircleRevealClipper({required this.fraction, required this.centerOffset});

  @override
  Rect getClip(Size size) {
    final maxRadius = sqrt(size.width * size.width + size.height * size.height);
    final radius = maxRadius * fraction;
    return Rect.fromCircle(center: centerOffset, radius: radius);
  }

  @override
  bool shouldReclip(CircleRevealClipper old) {
    return fraction != old.fraction;
  }
}
