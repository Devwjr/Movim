import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryLight = Color(0xFF6C63FF);
  static const Color secondaryLight = Color(0xFF00D9FF);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color errorLight = Color(0xFFFF5252);
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);

  static const Color primaryDark = Color(0xFF7C4DFF);
  static const Color secondaryDark = Color(0xFF00B0FF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color errorDark = Color(0xFFFF5252);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
}

class EditorColors {
  static const Map<String, Color> dracula = {
    'background': Color(0xFF282A36),
    'foreground': Color(0xFFF8F8F2),
    'selection': Color(0xFF44475A),
    'comment': Color(0xFF6272A4),
    'red': Color(0xFFFF5555),
    'orange': Color(0xFFFFB86C),
    'yellow': Color(0xFFF1FA8C),
    'green': Color(0xFF50FA7B),
    'purple': Color(0xFFBD93F9),
    'cyan': Color(0xFF8BE9FD),
    'pink': Color(0xFFFF79C6),
    'lineNumber': Color(0xFF6272A4),
    'cursor': Color(0xFFF8F8F2),
    'cursorLine': Color(0xFF282A36),
  };

  static const Map<String, Color> oneDark = {
    'background': Color(0xFF282C34),
    'foreground': Color(0xFFABB2BF),
    'selection': Color(0xFF3E4451),
    'comment': Color(0xFF5C6370),
    'red': Color(0xFFE06C75),
    'orange': Color(0xFFD19A66),
    'yellow': Color(0xFFE5C07B),
    'green': Color(0xFF98C379),
    'purple': Color(0xFFC678DD),
    'cyan': Color(0xFF56B6C2),
    'blue': Color(0xFF61AFEF),
    'lineNumber': Color(0xFF4B5263),
    'cursor': Color(0xFF528BFF),
    'cursorLine': Color(0xFF2C313A),
  };

  static const Map<String, Color> nord = {
    'background': Color(0xFF2E3440),
    'foreground': Color(0xFFD8DEE9),
    'selection': Color(0xFF434C5E),
    'comment': Color(0xFF4C566A),
    'red': Color(0xFFBF616A),
    'orange': Color(0xFFD08770),
    'yellow': Color(0xFFEBCB8B),
    'green': Color(0xFFA3BE8C),
    'purple': Color(0xFFB48EAD),
    'cyan': Color(0xFF88C0D0),
    'blue': Color(0xFF81A1C1),
    'lineNumber': Color(0xFF4C566A),
    'cursor': Color(0xFF88C0D0),
    'cursorLine': Color(0xFF3B4252),
  };

  static const Map<String, Color> tokyoNight = {
    'background': Color(0xFF1A1B26),
    'foreground': Color(0xFFC0CAF5),
    'selection': Color(0xFF33467C),
    'comment': Color(0xFF565F89),
    'red': Color(0xFFF7768E),
    'orange': Color(0xFFFF9E64),
    'yellow': Color(0xFFE0AF68),
    'green': Color(0xFF9ECE6A),
    'purple': Color(0xFFBB9AF7),
    'cyan': Color(0xFF7DCFFF),
    'blue': Color(0xFF7AA2F7),
    'pink': Color(0xFFC678DD),
    'lineNumber': Color(0xFF3B4261),
    'cursor': Color(0xFFC0CAF5),
    'cursorLine': Color(0xFF1E202E),
  };

  static const Map<String, Color> gruvboxDark = {
    'background': Color(0xFF282828),
    'foreground': Color(0xFFEBDBB2),
    'selection': Color(0xFF504945),
    'comment': Color(0xFF928374),
    'red': Color(0xFFFB4934),
    'orange': Color(0xFFFE8019),
    'yellow': Color(0xFFFABD2F),
    'green': Color(0xFFB8BB26),
    'purple': Color(0xFFD3869B),
    'cyan': Color(0xFF8EC07C),
    'blue': Color(0xFF83A598),
    'lineNumber': Color(0xFF665C54),
    'cursor': Color(0xFFEBDBB2),
    'cursorLine': Color(0xFF3C3836),
  };

  static const Map<String, Map<String, Color>> themes = {
    'Dracula': dracula,
    'One Dark': oneDark,
    'Nord': nord,
    'Tokyo Night': tokyoNight,
    'Gruvbox Dark': gruvboxDark,
  };
}

class SyntaxColors {
  static const Map<String, String> highlightGroups = {
    'keyword': 'purple',
    'function': 'blue',
    'string': 'green',
    'number': 'orange',
    'comment': 'comment',
    'operator': 'cyan',
    'class': 'yellow',
    'variable': 'foreground',
    'property': 'orange',
    'tag': 'red',
    'attribute': 'green',
    'value': 'cyan',
  };
}
