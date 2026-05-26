part of 'git_bloc.dart';

abstract class GitState extends Equatable {
  const GitState();

  @override
  List<Object?> get props => [];
}

class GitInitial extends GitState {
  const GitInitial();
}

class GitLoading extends GitState {
  const GitLoading();
}

class GitNotARepo extends GitState {
  const GitNotARepo();
}

class GitReady extends GitState {
  final List<GitStatusEntry> status;
  final List<GitBranch> branches;
  final String currentBranch;
  final int stagedCount;
  final int unstagedCount;
  final String repoPath;
  final String? diffContent;
  final String? lastCommitMessage;

  const GitReady({
    required this.status,
    required this.branches,
    required this.currentBranch,
    required this.stagedCount,
    required this.unstagedCount,
    required this.repoPath,
    this.diffContent,
    this.lastCommitMessage,
  });

  @override
  List<Object?> get props => [
        status,
        branches,
        currentBranch,
        stagedCount,
        unstagedCount,
        repoPath,
        diffContent,
        lastCommitMessage,
      ];

  GitReady copyWith({
    List<GitStatusEntry>? status,
    List<GitBranch>? branches,
    String? currentBranch,
    int? stagedCount,
    int? unstagedCount,
    String? repoPath,
    String? diffContent,
    String? lastCommitMessage,
  }) {
    return GitReady(
      status: status ?? this.status,
      branches: branches ?? this.branches,
      currentBranch: currentBranch ?? this.currentBranch,
      stagedCount: stagedCount ?? this.stagedCount,
      unstagedCount: unstagedCount ?? this.unstagedCount,
      repoPath: repoPath ?? this.repoPath,
      diffContent: diffContent ?? this.diffContent,
      lastCommitMessage: lastCommitMessage ?? this.lastCommitMessage,
    );
  }
}

class GitError extends GitState {
  final String message;

  const GitError(this.message);

  @override
  List<Object?> get props => [message];
}
