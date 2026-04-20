import 'package:go_router/go_router.dart';
import 'package:wealth_lens/domain/entities/asset.dart';
import 'package:wealth_lens/presentation/screens/add_edit_asset/add_edit_asset_screen.dart';
import 'package:wealth_lens/presentation/screens/analytics/analytics_screen.dart';
import 'package:wealth_lens/presentation/screens/asset_detail/asset_detail_screen.dart';
import 'package:wealth_lens/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:wealth_lens/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:wealth_lens/presentation/screens/settings/settings_screen.dart';
import 'package:wealth_lens/presentation/screens/splash/splash_screen.dart';
import 'package:wealth_lens/presentation/screens/transaction_log/transaction_log_screen.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String addAsset = '/asset/add';
  static const String assetDetail = '/asset/:id';
  static const String editAsset = '/asset/:id/edit';
  static const String transactions = '/asset/:id/transactions';
  static const String analytics = '/analytics';
  static const String settings = '/settings';

  static String assetDetailPath(String id) => '/asset/$id';
  static String editAssetPath(String id) => '/asset/$id/edit';
  static String transactionsPath(String id) => '/asset/$id/transactions';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.addAsset,
      name: 'addAsset',
      builder: (context, state) => const AddEditAssetScreen(),
    ),
    GoRoute(
      path: AppRoutes.assetDetail,
      name: 'assetDetail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AssetDetailScreen(assetId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.editAsset,
      name: 'editAsset',
      builder: (context, state) {
        final asset = state.extra as Asset?;
        return AddEditAssetScreen(asset: asset);
      },
    ),
    GoRoute(
      path: AppRoutes.transactions,
      name: 'transactions',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TransactionLogScreen(assetId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.analytics,
      name: 'analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
