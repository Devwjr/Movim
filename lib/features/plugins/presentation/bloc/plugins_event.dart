part of 'plugins_bloc.dart';

abstract class PluginsEvent extends Equatable {
  const PluginsEvent();

  @override
  List<Object?> get props => [];
}

class PluginsLoad extends PluginsEvent {
  const PluginsLoad();
}

class PluginsToggle extends PluginsEvent {
  final String pluginId;

  const PluginsToggle(this.pluginId);

  @override
  List<Object?> get props => [pluginId];
}

class PluginsInstall extends PluginsEvent {
  final String pluginId;

  const PluginsInstall(this.pluginId);

  @override
  List<Object?> get props => [pluginId];
}

class PluginsUninstall extends PluginsEvent {
  final String pluginId;

  const PluginsUninstall(this.pluginId);

  @override
  List<Object?> get props => [pluginId];
}
