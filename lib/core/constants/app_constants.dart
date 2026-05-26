class AppConstants {
  static const String appName = 'MobileVim';
  static const String appVersion = '1.0.0';
  
  static const String githubClientId = 'SEU_GITHUB_CLIENT_ID';
  static const String githubClientSecret = 'SEU_GITHUB_CLIENT_SECRET';
  static const String githubRedirectUri = 'mobilevim://auth/callback';
  static const List<String> githubScopes = [
    'repo',
    'user',
    'gist',
    'workflow',
  ];

  static const List<String> supportedLanguages = [
    'dart',
    'javascript',
    'typescript',
    'python',
    'java',
    'kotlin',
    'go',
    'rust',
    'c',
    'cpp',
    'html',
    'css',
    'scss',
    'json',
    'yaml',
    'markdown',
    'sql',
    'bash',
    'php',
    'ruby',
    'swift',
  ];

  static const List<String> webFrameworks = [
    'React',
    'Vue.js',
    'Angular',
    'Next.js',
    'Nuxt.js',
    'Svelte',
    'SvelteKit',
    'Remix',
    'Astro',
    'Flutter Web',
  ];

  static const List<String> backendFrameworks = [
    'Node.js (Express)',
    'Node.js (NestJS)',
    'Python (Django)',
    'Python (FastAPI)',
    'Python (Flask)',
    'Java (Spring Boot)',
    'Go (Gin)',
    'Go (Fiber)',
    'Rust (Actix)',
    'Rust (Rocket)',
    'PHP (Laravel)',
    'Ruby (Rails)',
  ];

  static const List<String> databases = [
    'PostgreSQL',
    'MySQL',
    'MongoDB',
    'Redis',
    'SQLite',
    'Firebase',
    'Supabase',
    'Prisma',
  ];

  static const Map<String, String> fileExtensions = {
    '.dart': 'dart',
    '.js': 'javascript',
    '.jsx': 'javascript',
    '.ts': 'typescript',
    '.tsx': 'typescript',
    '.py': 'python',
    '.java': 'java',
    '.kt': 'kotlin',
    '.go': 'go',
    '.rs': 'rust',
    '.c': 'c',
    '.cpp': 'cpp',
    '.h': 'c',
    '.hpp': 'cpp',
    '.html': 'html',
    '.htm': 'html',
    '.css': 'css',
    '.scss': 'scss',
    '.sass': 'scss',
    '.json': 'json',
    '.yaml': 'yaml',
    '.yml': 'yaml',
    '.md': 'markdown',
    '.sql': 'sql',
    '.sh': 'bash',
    '.bash': 'bash',
    '.zsh': 'bash',
    '.php': 'php',
    '.rb': 'ruby',
    '.swift': 'swift',
  };

  static const String defaultTerminalFont = 'JetBrainsMono';
  static const double defaultFontSize = 14.0;
  static const double defaultLineHeight = 1.5;
  static const int defaultTabSize = 2;
  
  static const List<String> defaultVimCommands = [
    'i', 'I', 'a', 'A', 'o', 'O',
    'h', 'j', 'k', 'l',
    'w', 'b', 'e',
    '0', r'$', '^',
    'gg', 'G',
    'dd', 'yy', 'p', 'P',
    'u', '<C-r>',
    'v', 'V', '<C-v>',
    ':', '/', '?',
  ];
}
