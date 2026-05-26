part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final double fontSize;
  final String fontFamily;
  final int tabSize;
  final bool expandTabs;
  final bool showLineNumbers;
  final bool wordWrap;
  final bool autoSave;
  final bool showInvisibles;
  final bool showMinimap;
  final String activeTheme;

  const SettingsState({
    this.themeMode = ThemeMode.dark,
    this.fontSize = 14.0,
    this.fontFamily = 'JetBrainsMono',
    this.tabSize = 2,
    this.expandTabs = true,
    this.showLineNumbers = true,
    this.wordWrap = false,
    this.autoSave = true,
    this.showInvisibles = false,
    this.showMinimap = false,
    this.activeTheme = 'Dracula',
  });

  @override
  List<Object?> get props => [
        themeMode,
        fontSize,
        fontFamily,
        tabSize,
        expandTabs,
        showLineNumbers,
        wordWrap,
        autoSave,
        showInvisibles,
        showMinimap,
        activeTheme,
      ];

  SettingsState copyWith({
    ThemeMode? themeMode,
    double? fontSize,
    String? fontFamily,
    int? tabSize,
    bool? expandTabs,
    bool? showLineNumbers,
    bool? wordWrap,
    bool? autoSave,
    bool? showInvisibles,
    bool? showMinimap,
    String? activeTheme,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      tabSize: tabSize ?? this.tabSize,
      expandTabs: expandTabs ?? this.expandTabs,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      wordWrap: wordWrap ?? this.wordWrap,
      autoSave: autoSave ?? this.autoSave,
      showInvisibles: showInvisibles ?? this.showInvisibles,
      showMinimap: showMinimap ?? this.showMinimap,
      activeTheme: activeTheme ?? this.activeTheme,
    );
  }
}
