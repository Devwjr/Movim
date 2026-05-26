import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/plugin_entity.dart';

part 'plugins_event.dart';
part 'plugins_state.dart';

class PluginsBloc extends Bloc<PluginsEvent, PluginsState> {
  final SharedPreferences _prefs;

  PluginsBloc({required SharedPreferences sharedPreferences})
      : _prefs = sharedPreferences,
        super(const PluginsInitial()) {
    on<PluginsLoad>(_onLoad);
    on<PluginsToggle>(_onToggle);
    on<PluginsInstall>(_onInstall);
    on<PluginsUninstall>(_onUninstall);
  }

  Future<void> _onLoad(
    PluginsLoad event,
    Emitter<PluginsState> emit,
  ) async {
    emit(const PluginsLoading());

    final savedStates = _prefs.getString('plugin_states') ?? '';
    final enabledIds = savedStates.isNotEmpty ? savedStates.split(',') : <String>[];

    final plugins = DefaultPlugins.plugins.map((p) {
      final isEnabled = enabledIds.contains(p.id);
      return p.copyWith(
        isEnabled: isEnabled,
        isInstalled: true,
      );
    }).toList();

    emit(PluginsReady(plugins: plugins));
  }

  Future<void> _onToggle(
    PluginsToggle event,
    Emitter<PluginsState> emit,
  ) async {
    if (state is! PluginsReady) return;
    final currentState = state as PluginsReady;

    final plugins = currentState.plugins.map((p) {
      if (p.id == event.pluginId) {
        return p.copyWith(isEnabled: !p.isEnabled);
      }
      return p;
    }).toList();

    _savePluginStates(plugins);
    emit(currentState.copyWith(plugins: plugins));
  }

  Future<void> _onInstall(
    PluginsInstall event,
    Emitter<PluginsState> emit,
  ) async {
    if (state is! PluginsReady) return;
    final currentState = state as PluginsReady;

    final plugins = currentState.plugins.map((p) {
      if (p.id == event.pluginId) {
        return p.copyWith(isInstalled: true, isEnabled: true);
      }
      return p;
    }).toList();

    _savePluginStates(plugins);
    emit(currentState.copyWith(plugins: plugins));
  }

  Future<void> _onUninstall(
    PluginsUninstall event,
    Emitter<PluginsState> emit,
  ) async {
    if (state is! PluginsReady) return;
    final currentState = state as PluginsReady;

    final plugins = currentState.plugins.map((p) {
      if (p.id == event.pluginId) {
        return p.copyWith(isInstalled: false, isEnabled: false);
      }
      return p;
    }).toList();

    _savePluginStates(plugins);
    emit(currentState.copyWith(plugins: plugins));
  }

  void _savePluginStates(List<PluginEntity> plugins) {
    final enabledIds = plugins.where((p) => p.isEnabled).map((p) => p.id).join(',');
    _prefs.setString('plugin_states', enabledIds);
  }
}
