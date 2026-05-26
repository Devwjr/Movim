part of 'git_bloc.dart';

abstract class GitEvent extends Equatable {
  const GitEvent();

  @override
  List<Object?> get props => [];
}

class GitLoadRepo extends GitEvent {
  final String path;

  const GitLoadRepo(this.path);

  @override
  List<Object?> get props => [path];
}

class GitRefreshStatus extends GitEvent {
  const GitRefreshStatus();
}

class GitStageFile extends GitEvent {
  final String filePath;

  const GitStageFile(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class GitUnstageFile extends GitEvent {
  final String filePath;

  const GitUnstageFile(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class GitCommit extends GitEvent {
  final String message;

  const GitCommit(this.message);

  @override
  List<Object?> get props => [message];
}

class GitCheckout extends GitEvent {
  final String branchName;

  const GitCheckout(this.branchName);

  @override
  List<Object?> get props => [branchName];
}

class GitShowDiff extends GitEvent {
  final bool staged;

  const GitShowDiff({this.staged = false});

  @override
  List<Object?> get props => [staged];
}
