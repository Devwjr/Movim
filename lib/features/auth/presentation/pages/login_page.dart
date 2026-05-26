import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uni_links/uni_links.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/themes/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
    context.read<AuthBloc>().add(const AuthCheckStatus());
  }

  void _initDeepLinkListener() {
    uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.scheme == 'mobilevim') {
        if (mounted) {
          context.read<AuthBloc>().add(AuthHandleCallback(uri));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, '/');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorDark,
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.backgroundDark,
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 40),
                    _buildTitle(),
                    const SizedBox(height: 16),
                    _buildSubtitle(),
                    const SizedBox(height: 48),
                    _buildLoginButton(),
                    const SizedBox(height: 24),
                    _buildFeatures(),
                    const SizedBox(height: 48),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.3),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'V',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: AppColors.backgroundDark,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'MobileVim',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
            letterSpacing: 2,
          ),
        ),
        Container(
          width: 100,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryDark,
                AppColors.secondaryDark,
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Sua IDE móvel estilo Neovim\npara desenvolvimento web e backend',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 14,
        height: 1.6,
        color: AppColors.textSecondaryDark,
      ),
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    context.read<AuthBloc>().add(const AuthLoginWithGithub());
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey[800],
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/github.png',
                        height: 24,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Continuar com GitHub',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildFeatures() {
    return Column(
      children: [
        _buildFeatureItem(
          icon: Icons.edit,
          title: 'Editor Vim',
          description: 'Navegação e comandos estilo Neovim',
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: Icons.terminal,
          title: 'Terminal Integrado',
          description: 'Acesse o shell diretamente do app',
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: Icons.folder_open,
          title: 'Explorador de Arquivos',
          description: 'Gerencie seus projetos com facilidade',
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: Icons.extension,
          title: 'Plugins & Temas',
          description: 'Personalize sua experiência',
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryDark.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryDark,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 12,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Text(
      'v1.0.0 - Desenvolvido para devs móveis',
      style: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 11,
        color: AppColors.textSecondaryDark.withOpacity(0.6),
      ),
    );
  }
}
