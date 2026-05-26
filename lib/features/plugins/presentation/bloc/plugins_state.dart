part of 'plugins_bloc.dart';

abstract class PluginsState extends Equatable {
  const PluginsState();

  @override
  List<Object?> get props => [];
}

class PluginsInitial extends PluginsState {
  const PluginsInitial();
}

class PluginsLoading extends PluginsState {
  const PluginsLoading();
}

class PluginsReady extends PluginsState {
  final List<PluginEntity> plugins;

  const PluginsReady({required this.plugins});

  @override
  List<Object?> get props => [plugins];

  PluginsReady copyWith({List<PluginEntity>? plugins}) {
    return PluginsReady(plugins: plugins ?? this.plugins);
  }
}

class PluginsError extends PluginsState {
  final String message;

  const PluginsError(this.message);

  @override
  List<Object?> get props => [message];
}
