part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoad extends SettingsEvent {
  const SettingsLoad();
}

class SettingsUpdateThemeMode extends SettingsEvent {
  final ThemeMode themeMode;

  const SettingsUpdateThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class SettingsUpdateFontSize extends SettingsEvent {
  final double fontSize;

  const SettingsUpdateFontSize(this.fontSize);

  @override
  List<Object?> get props => [fontSize];
}

class SettingsUpdateFontFamily extends SettingsEvent {
  final String fontFamily;

  const SettingsUpdateFontFamily(this.fontFamily);

  @override
  List<Object?> get props => [fontFamily];
}

class SettingsUpdateTabSize extends SettingsEvent {
  final int tabSize;

  const SettingsUpdateTabSize(this.tabSize);

  @override
  List<Object?> get props => [tabSize];
}

class SettingsUpdateExpandTabs extends SettingsEvent {
  final bool expandTabs;

  const SettingsUpdateExpandTabs(this.expandTabs);

  @override
  List<Object?> get props => [expandTabs];
}

class SettingsUpdateLineNumbers extends SettingsEvent {
  final bool showLineNumbers;

  const SettingsUpdateLineNumbers(this.showLineNumbers);

  @override
  List<Object?> get props => [showLineNumbers];
}

class SettingsUpdateWordWrap extends SettingsEvent {
  final bool wordWrap;

  const SettingsUpdateWordWrap(this.wordWrap);

  @override
  List<Object?> get props => [wordWrap];
}

class SettingsUpdateAutoSave extends SettingsEvent {
  final bool autoSave;

  const SettingsUpdateAutoSave(this.autoSave);

  @override
  List<Object?> get props => [autoSave];
}

class SettingsUpdateShowInvisibles extends SettingsEvent {
  final bool showInvisibles;

  const SettingsUpdateShowInvisibles(this.showInvisibles);

  @override
  List<Object?> get props => [showInvisibles];
}

class SettingsUpdateShowMinimap extends SettingsEvent {
  final bool showMinimap;

  const SettingsUpdateShowMinimap(this.showMinimap);

  @override
  List<Object?> get props => [showMinimap];
}

class SettingsUpdateActiveTheme extends SettingsEvent {
  final String themeName;

  const SettingsUpdateActiveTheme(this.themeName);

  @override
  List<Object?> get props => [themeName];
}

class SettingsReset extends SettingsEvent {
  const SettingsReset();
}
