import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/editor/presentation/pages/editor_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/terminal/presentation/pages/terminal_page.dart';
import '../../features/plugins/presentation/pages/plugins_page.dart';
import '../../features/templates/presentation/pages/templates_page.dart';
import '../../features/git/presentation/pages/git_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/editor':
        return MaterialPageRoute(builder: (_) => const EditorPage());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case '/terminal':
        return MaterialPageRoute(builder: (_) => const TerminalPage());
      case '/plugins':
        return MaterialPageRoute(builder: (_) => const PluginsPage());
      case '/templates':
        return MaterialPageRoute(builder: (_) => const TemplatesPage());
      case '/git':
        return MaterialPageRoute(builder: (_) => const GitPage());
      default:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
    }
  }

  static void navigateTo(BuildContext context, String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  static void navigateReplacement(BuildContext context, String routeName) {
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  static void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
