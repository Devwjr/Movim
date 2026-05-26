import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../auth/presentation/pages/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  final PermissionService _permissionService = PermissionService();
  bool _storageGranted = false;
  bool _isLoading = false;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      icon: Icons.edit_document,
      title: 'Bem-vindo ao MobileVim',
      description: 'Sua IDE móvel estilo Neovim para desenvolvimento web e backend, direto do seu celular.',
      color: AppColors.primaryDark,
    ),
    OnboardingStep(
      icon: Icons.folder_open,
      title: 'Acesso aos Arquivos',
      description: 'Precisamos de acesso ao armazenamento do seu dispositivo para que você possa editar seus projetos.',
      color: AppColors.secondaryDark,
      requiresPermission: true,
      permissionType: PermissionType.storage,
    ),
    OnboardingStep(
      icon: Icons.code,
      title: 'Pronto para Codar!',
      description: 'Você já pode começar a editar seus arquivos com comandos Vim, usar o terminal integrado e acessar templates de frameworks.',
      color: Colors.green,
      isLastStep: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkInitialPermissions();
  }

  Future<void> _checkInitialPermissions() async {
    final hasStorage = await _permissionService.hasStoragePermission();
    setState(() {
      _storageGranted = hasStorage;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
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
          child: Column(
            children: [
              _buildSkipButton(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_steps[index], index);
                  },
                ),
              ),
              _buildPageIndicator(),
              _buildBottomButtons(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        onPressed: _completeOnboarding,
        child: Text(
          'Pular',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            color: AppColors.textSecondaryDark,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingStep step, int index) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(step),
          const SizedBox(height: 48),
          _buildTitle(step),
          const SizedBox(height: 16),
          _buildDescription(step),
          if (step.requiresPermission) ...[
            const SizedBox(height: 32),
            _buildPermissionButton(step),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(OnboardingStep step) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: step.color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          step.icon,
          size: 56,
          color: step.color,
        ),
      ),
    );
  }

  Widget _buildTitle(OnboardingStep step) {
    return Text(
      step.title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
      ),
    );
  }

  Widget _buildDescription(OnboardingStep step) {
    return Text(
      step.description,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 14,
        height: 1.6,
        color: AppColors.textSecondaryDark,
      ),
    );
  }

  Widget _buildPermissionButton(OnboardingStep step) {
    if (step.permissionType == PermissionType.storage) {
      return Column(
        children: [
          if (_storageGranted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Permissão concedida!',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _requestStoragePermission,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.folder_open, size: 22),
                label: const Text(
                  'Conceder acesso ao armazenamento',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _permissionService.openAppSettings(),
            child: Text(
              'Abrir configurações do app',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                color: AppColors.textSecondaryDark,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _requestStoragePermission() async {
    setState(() => _isLoading = true);
    
    try {
      final granted = await _permissionService.requestStoragePermission();
      setState(() {
        _storageGranted = granted;
        _isLoading = false;
      });
      
      if (granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão concedida com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: AppColors.errorDark,
        ),
      );
    }
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _steps.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? _steps[_currentPage].color
                : AppColors.textSecondaryDark.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(bool isDark) {
    final currentStep = _steps[_currentPage];
    final isLastStep = currentStep.isLastStep;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                'Voltar',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  color: AppColors.textSecondaryDark,
                  fontSize: 14,
                ),
              ),
            )
          else
            const SizedBox(width: 80),
          const Spacer(),
          SizedBox(
            width: 140,
            child: ElevatedButton(
              onPressed: () {
                if (isLastStep) {
                  _completeOnboarding();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: currentStep.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isLastStep ? 'Começar' : 'Próximo',
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _completeOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}

class OnboardingStep {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool requiresPermission;
  final PermissionType? permissionType;
  final bool isLastStep;

  const OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.requiresPermission = false,
    this.permissionType,
    this.isLastStep = false,
  });
}

enum PermissionType {
  storage,
  camera,
  microphone,
  location,
}
