import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/aadhaar_entry_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/professional_verification_screen.dart';
import '../../features/health_official/screens/command_center_screen.dart';
import '../../features/health_official/screens/district_details_screen.dart';
import '../../features/health_official/screens/ai_copilot_screen.dart';
import '../../features/health_official/screens/broadcast_screen.dart';
import '../../features/field_worker/screens/field_dashboard_screen.dart';
import '../../features/field_worker/screens/report_form_screen.dart';
import '../../features/field_worker/screens/ai_copilot_screen.dart' as field_worker_ai;
import '../../features/shared/screens/educational_module_screen.dart';
import '../../features/field_worker/screens/mcp_card_screen.dart';
import '../../features/citizen/screens/citizen_dashboard_screen.dart';
import '../../features/citizen/screens/concern_report_screen.dart';
import '../../features/citizen/screens/ai_copilot_screen.dart' as citizen_ai;
import '../../features/shared/screens/notifications_screen.dart';
import '../../features/shared/screens/profile_screen.dart';
import '../../features/shared/screens/settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final path = state.fullPath ?? '';
      
      // Allow splash screen to show without redirect
      if (path == '/splash') {
        return null;
      }
      
      // Define auth-related routes
      final isAuthRoute = ['/welcome', '/aadhaar-entry', '/otp-verification', '/professional-verification']
          .contains(path);
      
      // If user is not authenticated, only allow auth routes
      if (!authProvider.isAuthenticated) {
        return isAuthRoute ? null : '/welcome';
      }
      
      // If user is authenticated but not verified (for professionals)
      if (authProvider.currentUser != null && 
          !authProvider.currentUser!.isVerified &&
          !authProvider.currentUser!.isCitizen) {
        if (path != '/professional-verification') {
          return '/professional-verification';
        }
        return null;
      }
      
      // Redirect authenticated users away from auth routes to their dashboard
      if (isAuthRoute && authProvider.currentUser != null) {
        switch (authProvider.currentUser!.role) {
          case UserRole.healthOfficial:
            return '/health-official/dashboard';
          case UserRole.ashaWorker:
            return '/field-worker/dashboard';
          case UserRole.citizen:
            return '/citizen/dashboard';
        }
      }
      
      // Allow navigation to all other routes
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Welcome and Authentication Routes
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/aadhaar-entry',
        builder: (context, state) => const AadhaarEntryScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: '/professional-verification',
        builder: (context, state) => const ProfessionalVerificationScreen(),
      ),
      
      // Health Official Routes
      GoRoute(
        path: '/health-official/dashboard',
        builder: (context, state) => const CommandCenterScreen(),
      ),
      GoRoute(
        path: '/health-official/district/:districtId',
        builder: (context, state) {
          final districtId = state.pathParameters['districtId']!;
          return DistrictDetailsScreen(districtId: districtId);
        },
      ),
      GoRoute(
        path: '/health-official/ai-copilot',
        builder: (context, state) => const AiCopilotScreen(),
      ),
      GoRoute(
        path: '/health-official/broadcast',
        builder: (context, state) => const BroadcastScreen(),
      ),
      
      // Field Worker (ASHA) Routes
      GoRoute(
        path: '/field-worker/dashboard',
        builder: (context, state) => const FieldDashboardScreen(),
      ),
      GoRoute(
        path: '/field-worker/report-form',
        builder: (context, state) => const ReportFormScreen(),
      ),
      GoRoute(
        path: '/field-worker/education',
        builder: (context, state) => const EducationalModuleScreen(),
      ),
      GoRoute(
        path: '/field-worker/mcp-card',
        builder: (context, state) => const McpCardScreen(),
      ),
      GoRoute(
        path: '/field-worker/ai-copilot',
        builder: (context, state) => const field_worker_ai.FieldWorkerAiCopilotScreen(),
      ),
      
      // Citizen Routes
      GoRoute(
        path: '/citizen/dashboard',
        builder: (context, state) => const CitizenDashboardScreen(),
      ),
      GoRoute(
        path: '/citizen/concern-report',
        builder: (context, state) => const ConcernReportScreen(),
      ),
      GoRoute(
        path: '/citizen/ai-copilot',
        builder: (context, state) => const citizen_ai.CitizenAiCopilotScreen(),
      ),
      
      // Shared Routes
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/welcome'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
