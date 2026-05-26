import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences _prefs;

  SettingsBloc({required SharedPreferences sharedPreferences})
      : _prefs = sharedPreferences,
        super(const SettingsState()) {
    on<SettingsLoad>(_onLoad);
    on<SettingsUpdateThemeMode>(_onUpdateThemeMode);
    on<SettingsUpdateFontSize>(_onUpdateFontSize);
    on<SettingsUpdateFontFamily>(_onUpdateFontFamily);
    on<SettingsUpdateTabSize>(_onUpdateTabSize);
    on<SettingsUpdateExpandTabs>(_onUpdateExpandTabs);
    on<SettingsUpdateLineNumbers>(_onUpdateLineNumbers);
    on<SettingsUpdateWordWrap>(_onUpdateWordWrap);
    on<SettingsUpdateAutoSave>(_onUpdateAutoSave);
    on<SettingsUpdateShowInvisibles>(_onUpdateShowInvisibles);
    on<SettingsUpdateShowMinimap>(_onUpdateShowMinimap);
    on<SettingsUpdateActiveTheme>(_onUpdateActiveTheme);
    on<SettingsReset>(_onReset);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    add(const SettingsLoad());
  }

  Future<void> _onLoad(
    SettingsLoad event,
    Emitter<SettingsState> emit,
  ) async {
    final themeModeIndex = _prefs.getInt('theme_mode') ?? 1;
    final fontSize = _prefs.getDouble('font_size') ?? 14.0;
    final fontFamily = _prefs.getString('font_family') ?? 'JetBrainsMono';
    final tabSize = _prefs.getInt('tab_size') ?? 2;
    final expandTabs = _prefs.getBool('expand_tabs') ?? true;
    final lineNumbers = _prefs.getBool('line_numbers') ?? true;
    final wordWrap = _prefs.getBool('word_wrap') ?? false;
    final autoSave = _prefs.getBool('auto_save') ?? true;
    final showInvisibles = _prefs.getBool('show_invisibles') ?? false;
    final showMinimap = _prefs.getBool('show_minimap') ?? false;
    final activeTheme = _prefs.getString('active_theme') ?? 'Dracula';

    emit(SettingsState(
      themeMode: ThemeMode.values[themeModeIndex],
      fontSize: fontSize,
      fontFamily: fontFamily,
      tabSize: tabSize,
      expandTabs: expandTabs,
      showLineNumbers: lineNumbers,
      wordWrap: wordWrap,
      autoSave: autoSave,
      showInvisibles: showInvisibles,
      showMinimap: showMinimap,
      activeTheme: activeTheme,
    ));
  }

  Future<void> _onUpdateThemeMode(
    SettingsUpdateThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    await _prefs.setInt('theme_mode', event.themeMode.index);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _onUpdateFontSize(
    SettingsUpdateFontSize event,
    Emitter<SettingsState> emit,
  ) async {
    final clamped = event.fontSize.clamp(8.0, 32.0);
    await _prefs.setDouble('font_size', clamped);
    emit(state.copyWith(fontSize: clamped));
  }

  Future<void> _onUpdateFontFamily(
    SettingsUpdateFontFamily event,
    Emitter<SettingsState> emit,
  ) async {
    await _prefs.setString('font_family', event.fontFamily);
    emit(state.copyWith(fontFamily: event.fontFamily));
  }

  Future<void> _onUpdateTabSize(
    SettingsUpdateTabSize event,
    Emitter<SettingsState> emit,
  ) async {
    final clamped = event.tabSize.clamp(1, 8);
    await _prefs.setInt('tab_size', clamped);
    emit(state.copyWith(tabSize: clamped));
  }

  Future<void> _onUpdateExpandTabs(
    SettingsUpdateExpandTabs event,
    Emitter<SettingsState> emit,
  ) async {
    await _prefs.setBool('expand_tabs', event.expandTabs);
    emit(state.copyWith(expandTabs: event.expandTabs));
  }

  Future<void> _onUpdateLineNumbers(
    SettingsUpdateLineNumbers event,
    Emitter<SettingsState> emit,
  ) async {
    await _prefs.setBool('line_numbers', event.showLineNumbers);
    emit(state.copyWith(showLineNumbers: event.showLineNumbers));
  }

  Future<void> _onUpdateWordWrap(
    SettingsUpdateWordWrap event,
    Emitter<SettingsState> emit,
  ) async {
    await _prefs.setBool('word_wrap', event.wordWrap);
    emit(state.copyWith(wordWrap: event.wordWrap));
  }

  Future<void> _onUpdateAutoSave(
    SettingsUpdateAutoSave event,
    Emitter<SettingsState> emit,
  ) async {
    await _prefs.setBool('auto_save', event.autoSave);
    emit(state.copyWith(autoSave: event.autoSave));
  }

  Future<void> _onUpdateShowInvisibles(
    SettingsUpdateShowInvisibles event,
    Emitter<SettingsState> emit,
  ) async {
    await _prefs.setBool('show_invisibles', event.showInvisibles);
    emit(state.copyWith(showInvisibles: event.showInvisibles));
  }

  Future<void> _onUpdateShowMinimap(
    SettingsUpdateShowMinimap event,
    Emitter<SettingsState> emit,
  ) async {
    await _prefs.setBool('show_minimap', event.showMinimap);
    emit(state.copyWith(showMinimap: event.showMinimap));
  }

  Future<void> _onUpdateActiveTheme(
    SettingsUpdateActiveTheme event,
    Emitter<SettingsState> emit,
  ) async {
    await _prefs.setString('active_theme', event.themeName);
    emit(state.copyWith(activeTheme: event.themeName));
  }

  Future<void> _onReset(
    SettingsReset event,
    Emitter<SettingsState> emit,
  ) async {
    await _prefs.clear();
    emit(const SettingsState());
  }
}
