import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/nord.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:flutter_highlight/themes/gruvbox-dark.dart';
import 'package:highlight/highlight.dart' as hl;
import '../../../../core/themes/app_colors.dart';

class SyntaxHighlighter {
  static final Map<String, String> _languageMap = {
    'dart': 'dart',
    'javascript': 'javascript',
    'js': 'javascript',
    'typescript': 'typescript',
    'ts': 'typescript',
    'jsx': 'javascript',
    'tsx': 'typescript',
    'python': 'python',
    'py': 'python',
    'java': 'java',
    'kotlin': 'kotlin',
    'kt': 'kotlin',
    'go': 'go',
    'golang': 'go',
    'rust': 'rust',
    'rs': 'rust',
    'c': 'c',
    'cpp': 'cpp',
    'c++': 'cpp',
    'h': 'c',
    'hpp': 'cpp',
    'html': 'xml',
    'htm': 'xml',
    'css': 'css',
    'scss': 'scss',
    'sass': 'scss',
    'json': 'json',
    'yaml': 'yaml',
    'yml': 'yaml',
    'markdown': 'markdown',
    'md': 'markdown',
    'sql': 'sql',
    'bash': 'bash',
    'sh': 'bash',
    'zsh': 'bash',
    'shell': 'bash',
    'php': 'php',
    'ruby': 'ruby',
    'rb': 'ruby',
    'swift': 'swift',
    'lua': 'lua',
    'vim': 'vim',
    'xml': 'xml',
    'ini': 'ini',
    'toml': 'toml',
    'dockerfile': 'dockerfile',
    'gitignore': 'plaintext',
  };

  static final Map<String, Map<String, TextStyle>> _themes = {
    'Dracula': draculaTheme,
    'One Dark': atomOneDarkTheme,
    'Nord': nordTheme,
    'Tokyo Night': tokyoNightTheme,
    'Gruvbox Dark': gruvboxDarkTheme,
  };

  static String? getLanguageFromExtension(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    return _languageMap[ext];
  }

  static String? getLanguageFromPath(String path) {
    final parts = path.split('.');
    if (parts.length > 1) {
      return getLanguageFromExtension(parts.last);
    }
    return null;
  }

  static List<TextSpan> highlightCode({
    required String text,
    String? language,
    String themeName = 'Dracula',
    double fontSize = 14.0,
    String fontFamily = 'JetBrainsMono',
  }) {
    if (text.isEmpty) {
      return [TextSpan(text: '', style: _getBaseStyle(fontSize, fontFamily))];
    }

    final lang = language ?? 'plaintext';
    final theme = _themes[themeName] ?? draculaTheme;

    try {
      final result = hl.highlight.parse(
        text,
        language: lang,
      );

      return _convertNodesToSpans(
        result.nodes,
        theme,
        fontSize,
        fontFamily,
      );
    } catch (e) {
      return [TextSpan(text: text, style: _getBaseStyle(fontSize, fontFamily))];
    }
  }

  static List<TextSpan> _convertNodesToSpans(
    List<hl.Node>? nodes,
    Map<String, TextStyle> theme,
    double fontSize,
    String fontFamily,
  ) {
    final spans = <TextSpan>[];

    if (nodes == null) return spans;

    for (final node in nodes) {
      if (node.children != null && node.children!.isNotEmpty) {
        final nodeSpans = _convertNodesToSpans(
          node.children,
          theme,
          fontSize,
          fontFamily,
        );

        if (nodeSpans.isNotEmpty) {
          final style = _getStyleFromClassName(
            node.className,
            theme,
            fontSize,
            fontFamily,
          );
          
          if (style != null) {
            spans.add(TextSpan(
              children: nodeSpans,
              style: style,
            ));
          } else {
            spans.addAll(nodeSpans);
          }
        }
      } else {
        spans.add(TextSpan(
          text: node.value,
          style: _getStyleFromClassName(
            node.className,
            theme,
            fontSize,
            fontFamily,
          ),
        ));
      }
    }

    return spans;
  }

  static TextStyle? _getStyleFromClassName(
    String? className,
    Map<String, TextStyle> theme,
    double fontSize,
    String fontFamily,
  ) {
    if (className == null) return null;

    final classes = className.split(' ');
    
    TextStyle? style;
    for (final cls in classes) {
      final themeStyle = theme['.$cls'];
      if (themeStyle != null) {
        style = (style ?? const TextStyle()).merge(themeStyle);
      }
    }

    return (style ?? const TextStyle()).merge(TextStyle(
      fontSize: fontSize,
      fontFamily: fontFamily,
      height: 1.2,
    ));
  }

  static TextStyle _getBaseStyle(double fontSize, String fontFamily) {
    return TextStyle(
      fontSize: fontSize,
      fontFamily: fontFamily,
      height: 1.2,
      color: AppColors.textPrimaryDark,
    );
  }

  static List<String> get supportedLanguages => 
      _languageMap.keys.toSet().toList()..sort();

  static List<String> get supportedThemes => _themes.keys.toList();

  static Map<String, TextStyle> getTheme(String themeName) {
    return _themes[themeName] ?? draculaTheme;
  }
}

final Map<String, TextStyle> tokyoNightTheme = {
  'root': TextStyle(
    backgroundColor: const Color(0xFF1A1B26),
    color: const Color(0xFFC0CAF5),
  ),
  'comment': TextStyle(color: const Color(0xFF565F89), fontStyle: FontStyle.italic),
  'quote': TextStyle(color: const Color(0xFF565F89), fontStyle: FontStyle.italic),
  'variable': TextStyle(color: const Color(0xFFF7768E)),
  'template-variable': TextStyle(color: const Color(0xFFF7768E)),
  'tag': TextStyle(color: const Color(0xFFF7768E)),
  'name': TextStyle(color: const Color(0xFFF7768E)),
  'selector-id': TextStyle(color: const Color(0xFFF7768E)),
  'selector-class': TextStyle(color: const Color(0xFFF7768E)),
  'regexp': TextStyle(color: const Color(0xFFE0AF68)),
  'deletion': TextStyle(color: const Color(0xFFF7768E)),
  'string': TextStyle(color: const Color(0xFF9ECE6A)),
  'symbol': TextStyle(color: const Color(0xFF9ECE6A)),
  'bullet': TextStyle(color: const Color(0xFF9ECE6A)),
  'addition': TextStyle(color: const Color(0xFF9ECE6A)),
  'title': TextStyle(color: const Color(0xFFE0AF68)),
  'section': TextStyle(color: const Color(0xFFE0AF68)),
  'attribute': TextStyle(color: const Color(0xFFE0AF68)),
  'literal': TextStyle(color: const Color(0xFFFF9E64)),
  'type': TextStyle(color: const Color(0xFF2AC3DE)),
  'params': TextStyle(color: const Color(0xFFC0CAF5)),
  'link': TextStyle(color: const Color(0xFF2AC3DE)),
  'keyword': TextStyle(color: const Color(0xFFBB9AF7)),
  'selector-tag': TextStyle(color: const Color(0xFFBB9AF7)),
  'built_in': TextStyle(color: const Color(0xFF7AA2F7)),
  'meta': TextStyle(color: const Color(0xFF7AA2F7)),
  'meta-keyword': TextStyle(color: const Color(0xFF7AA2F7)),
  'function': TextStyle(color: const Color(0xFF7AA2F7)),
  'class': TextStyle(color: const Color(0xFF7AA2F7)),
  'meta-string': TextStyle(color: const Color(0xFFE0AF68)),
};
