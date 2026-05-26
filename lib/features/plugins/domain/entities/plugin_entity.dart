import 'package:equatable/equatable.dart';

enum PluginType {
  syntax,
  lsp,
  formatter,
  snippet,
  theme,
  utility,
  integration,
}

class PluginEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? author;
  final String version;
  final PluginType type;
  final List<String> tags;
  final bool isEnabled;
  final bool isInstalled;
  final Map<String, dynamic> config;
  final String? icon;
  final String? repository;
  final DateTime? installedAt;
  final DateTime? updatedAt;

  const PluginEntity({
    required this.id,
    required this.name,
    required this.description,
    this.author,
    this.version = '1.0.0',
    this.type = PluginType.utility,
    this.tags = const [],
    this.isEnabled = false,
    this.isInstalled = false,
    this.config = const {},
    this.icon,
    this.repository,
    this.installedAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        author,
        version,
        type,
        tags,
        isEnabled,
        isInstalled,
        config,
        icon,
        repository,
        installedAt,
        updatedAt,
      ];

  PluginEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? author,
    String? version,
    PluginType? type,
    List<String>? tags,
    bool? isEnabled,
    bool? isInstalled,
    Map<String, dynamic>? config,
    String? icon,
    String? repository,
    DateTime? installedAt,
    DateTime? updatedAt,
  }) {
    return PluginEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      author: author ?? this.author,
      version: version ?? this.version,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      isEnabled: isEnabled ?? this.isEnabled,
      isInstalled: isInstalled ?? this.isInstalled,
      config: config ?? this.config,
      icon: icon ?? this.icon,
      repository: repository ?? this.repository,
      installedAt: installedAt ?? this.installedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DefaultPlugins {
  static final List<PluginEntity> plugins = [
    PluginEntity(
      id: 'vim-emulation',
      name: 'Vim Emulation',
      description: 'Comandos e modos Vim completos no editor',
      author: 'MobileVim',
      version: '1.0.0',
      type: PluginType.syntax,
      tags: ['vim', 'editor', 'navigation'],
      isEnabled: true,
      isInstalled: true,
      icon: '⌨️',
    ),
    PluginEntity(
      id: 'syntax-highlighting',
      name: 'Syntax Highlighting',
      description: 'Realce de sintaxe para múltiplas linguagens',
      author: 'MobileVim',
      version: '1.0.0',
      type: PluginType.syntax,
      tags: ['syntax', 'highlighting', 'languages'],
      isEnabled: true,
      isInstalled: true,
      icon: '🎨',
    ),
    PluginEntity(
      id: 'file-explorer',
      name: 'File Explorer',
      description: 'Explorador de arquivos estilo NERDTree',
      author: 'MobileVim',
      version: '1.0.0',
      type: PluginType.utility,
      tags: ['file', 'explorer', 'navigation'],
      isEnabled: true,
      isInstalled: true,
      icon: '📁',
    ),
    PluginEntity(
      id: 'terminal',
      name: 'Terminal Integrado',
      description: 'Terminal shell dentro do editor',
      author: 'MobileVim',
      version: '1.0.0',
      type: PluginType.utility,
      tags: ['terminal', 'shell', 'command'],
      isEnabled: true,
      isInstalled: true,
      icon: '🖥️',
    ),
    PluginEntity(
      id: 'autocomplete',
      name: 'Auto Complete',
      description: 'Autocompletar inteligente para código',
      author: 'MobileVim',
      version: '1.0.0',
      type: PluginType.lsp,
      tags: ['autocomplete', 'lsp', 'intellisense'],
      isEnabled: true,
      isInstalled: true,
      icon: '✨',
    ),
    PluginEntity(
      id: 'github-integration',
      name: 'GitHub Integration',
      description: 'Integração com GitHub para repos e Gists',
      author: 'MobileVim',
      version: '1.0.0',
      type: PluginType.integration,
      tags: ['github', 'git', 'sync'],
      isEnabled: true,
      isInstalled: true,
      icon: '🐙',
    ),
    PluginEntity(
      id: 'snippets',
      name: 'Code Snippets',
      description: 'Snippets de código para múltiplas linguagens',
      author: 'MobileVim',
      version: '1.0.0',
      type: PluginType.snippet,
      tags: ['snippets', 'templates', 'code'],
      isEnabled: false,
      isInstalled: true,
      icon: '📝',
    ),
    PluginEntity(
      id: 'formatter',
      name: 'Code Formatter',
      description: 'Formatador automático de código',
      author: 'MobileVim',
      version: '1.0.0',
      type: PluginType.formatter,
      tags: ['format', 'prettier', 'lint'],
      isEnabled: false,
      isInstalled: true,
      icon: '🔧',
    ),
    PluginEntity(
      id: 'theme-dracula',
      name: 'Dracula Theme',
      description: 'Tema Dracula popular para MobileVim',
      author: 'MobileVim',
      version: '1.0.0',
      type: PluginType.theme,
      tags: ['theme', 'dark', 'dracula'],
      isEnabled: true,
      isInstalled: true,
      icon: '🧛',
    ),
    PluginEntity(
      id: 'theme-one-dark',
      name: 'One Dark Theme',
      description: 'Tema One Dark baseado no Atom',
      author: 'MobileVim',
      version: '1.0.0',
      type: PluginType.theme,
      tags: ['theme', 'dark', 'atom'],
      isEnabled: false,
      isInstalled: true,
      icon: '🌑',
    ),
    PluginEntity(
      id: 'theme-nord',
      name: 'Nord Theme',
      description: 'Tema ártico Nord',
      author: 'MobileVim',
      version: '1.0.0',
      type: PluginType.theme,
      tags: ['theme', 'dark', 'nord', 'arctic'],
      isEnabled: false,
      isInstalled: true,
      icon: '❄️',
    ),
    PluginEntity(
      id: 'theme-tokyo-night',
      name: 'Tokyo Night Theme',
      description: 'Tema inspirado em Tokyo',
      author: 'MobileVim',
      version: '1.0.0',
      type: PluginType.theme,
      tags: ['theme', 'dark', 'japan'],
      isEnabled: false,
      isInstalled: true,
      icon: '🌃',
    ),
    PluginEntity(
      id: 'theme-gruvbox',
      name: 'Gruvbox Theme',
      description: 'Tema retro com cores quentes',
      author: 'MobileVim',
      version: '1.0.0',
      type: PluginType.theme,
      tags: ['theme', 'dark', 'retro'],
      isEnabled: false,
      isInstalled: true,
      icon: '🔥',
    ),
    PluginEntity(
      id: 'markdown-preview',
      name: 'Markdown Preview',
      description: 'Visualizador de Markdown em tempo real',
      author: 'MobileVim',
      version: '1.0.0',
      type: PluginType.utility,
      tags: ['markdown', 'preview', 'docs'],
      isEnabled: false,
      isInstalled: true,
      icon: '📄',
    ),
    PluginEntity(
      id: 'git-status',
      name: 'Git Status',
      description: 'Mostra status do Git no editor',
      author: 'MobileVim',
      version: '1.0.0',
      type: PluginType.integration,
      tags: ['git', 'status', 'diff'],
      isEnabled: false,
      isInstalled: true,
      icon: '📊',
    ),
  ];

  static final List<PluginEntity> availableThemes = plugins
      .where((p) => p.type == PluginType.theme)
      .toList();
}
