import 'package:go_router/go_router.dart';
import 'package:turf_booking/core/data/mock_data.dart';
import 'package:turf_booking/features/client/screens/checkout_screen.dart';
import 'package:turf_booking/features/client/screens/home_screen.dart';
import 'package:turf_booking/features/client/screens/turf_detail_screen.dart';
import 'package:turf_booking/features/landing_screen.dart';
import 'package:turf_booking/features/owner/screens/owner_dashboard.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/client/home',
      builder: (context, state) => const ClientHomeScreen(),
    ),
    GoRoute(
      path: '/client/turf/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TurfDetailScreen(turfId: id);
      },
    ),
    GoRoute(
      path: '/client/checkout',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ClientCheckoutScreen(
          turf: extra['turf'] as TurfModel,
          date: extra['date'] as DateTime,
          slots: extra['slots'] as List<String>,
        );
      },
    ),
    GoRoute(
      path: '/owner/dashboard',
      builder: (context, state) => const OwnerDashboard(),
    ),
  ],
);
