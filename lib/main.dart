import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'theme/app_theme.dart';
import 'services/auth_provider.dart';
import 'services/services_provider.dart';
import 'services/messages_provider.dart';
import 'models/models.dart';

import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_service_screen.dart';
import 'screens/service_detail_screen.dart';
import 'screens/messages_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // French locale for timeago
  timeago.setLocaleMessages('fr', timeago.FrMessages());

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const JeunesseActiveApp());
}

class JeunesseActiveApp extends StatelessWidget {
  const JeunesseActiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
        ChangeNotifierProvider(create: (_) => MessagesProvider()),
      ],
      child: MaterialApp(
        title: 'JeunesseActive',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _fadeRoute(const SplashScreen(), settings);

      case '/welcome':
        return _slideRoute(const WelcomeScreen(), settings);

      case '/login':
        final args = settings.arguments as Map<String, dynamic>?;
        final userType = args?['userType'] as UserType? ?? UserType.employee;
        return _slideRoute(LoginScreen(userType: userType), settings);

      case '/home':
        return _fadeRoute(const HomeScreen(), settings);

      case '/edit-profile':
        return _slideRoute(const EditProfileScreen(), settings);

      case '/add-service':
        return _slideRoute(const AddServiceScreen(), settings);

      case '/service-detail':
        final args = settings.arguments as Map<String, dynamic>;
        final offer = args['offer'] as ServiceOffer;
        final user = args['user'] as UserModel?;
        return _slideRoute(
          ServiceDetailScreen(offer: offer, user: user),
          settings,
        );

      case '/chat':
        final args = settings.arguments as Map<String, dynamic>;
        final conv = args['conversation'] as ConversationModel;
        return _slideRoute(ChatScreen(conversation: conv), settings);

      case '/messages':
        return _slideRoute(const MessagesScreen(), settings);

      case '/user-profile':
        final args2 = settings.arguments as Map<String, dynamic>;
        final profileUser = args2['user'] as UserModel;
        return _slideRoute(_UserProfileScreen(user: profileUser), settings);

      default:
        return _fadeRoute(const SplashScreen(), settings);
    }
  }

  PageRoute _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  PageRoute _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}

// Simple user profile view screen (for map user-profile route)
class _UserProfileScreen extends StatelessWidget {
  final UserModel user;
  const _UserProfileScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            onPressed: () => Navigator.of(context).pushNamed('/messages'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            _buildAvatar(),
            const SizedBox(height: 12),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (user.location.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF6C757D)),
                  const SizedBox(width: 4),
                  Text(
                    user.location,
                    style: const TextStyle(color: Color(0xFF6C757D), fontSize: 13),
                  ),
                ],
              ),
            ],
            if (user.bio.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Text(
                  user.bio,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF6C757D), height: 1.5),
                ),
              ),
            ],
            if (user.skills.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.skills
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A3D62).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            s,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0A3D62),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initials = user.name.trim().isNotEmpty
        ? user.name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : '?';
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A3D62), Color(0xFFFF6B35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
