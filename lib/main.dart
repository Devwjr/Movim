import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/service_locator.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/editor/presentation/bloc/editor_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/plugins/presentation/bloc/plugins_bloc.dart';
import 'features/templates/presentation/bloc/templates_bloc.dart';
import 'features/git/presentation/bloc/git_bloc.dart';
import 'core/services/git_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await setupServiceLocator();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc(
            sharedPreferences: sharedPreferences,
          ),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: getIt(),
            secureStorage: getIt(),
          ),
        ),
        BlocProvider<EditorBloc>(
          create: (context) => EditorBloc(
            fileRepository: getIt(),
            settingsBloc: context.read<SettingsBloc>(),
          ),
        ),
        BlocProvider<PluginsBloc>(
          create: (context) => PluginsBloc(
            sharedPreferences: sharedPreferences,
          ),
        ),
        BlocProvider<TemplatesBloc>(
          create: (context) => TemplatesBloc(),
        ),
        BlocProvider<GitBloc>(
          create: (context) => GitBloc(
            gitService: getIt<GitService>(),
          ),
        ),
      ],
      child: const MobileVimApp(),
    ),
  );
}
