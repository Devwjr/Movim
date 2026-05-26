import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/git_service.dart';

part 'git_event.dart';
part 'git_state.dart';

class GitBloc extends Bloc<GitEvent, GitState> {
  final GitService _gitService;

  GitBloc({required GitService gitService})
      : _gitService = gitService,
        super(const GitInitial()) {
    on<GitLoadRepo>(_onLoadRepo);
    on<GitRefreshStatus>(_onRefreshStatus);
    on<GitStageFile>(_onStageFile);
    on<GitUnstageFile>(_onUnstageFile);
    on<GitCommit>(_onCommit);
    on<GitCheckout>(_onCheckout);
    on<GitShowDiff>(_onShowDiff);
  }

  Future<void> _onLoadRepo(
    GitLoadRepo event,
    Emitter<GitState> emit,
  ) async {
    emit(const GitLoading());

    await _gitService.checkGitRepo(event.path);

    if (!_gitService.isGitRepo) {
      emit(const GitNotARepo());
      return;
    }

    await Future.wait([
      _gitService.getStatus(event.path),
      _gitService.getBranches(event.path),
    ]);

    emit(GitReady(
      status: _gitService.currentStatus,
      branches: _gitService.currentBranches,
      currentBranch: _gitService.currentBranch,
      stagedCount: _gitService.currentStatus.where((e) => e.isStaged).length,
      unstagedCount: _gitService.currentStatus.where((e) => !e.isStaged).length,
      repoPath: event.path,
    ));
  }

  Future<void> _onRefreshStatus(
    GitRefreshStatus event,
    Emitter<GitState> emit,
  ) async {
    if (state is! GitReady) return;
    final currentState = state as GitReady;

    await _gitService.getStatus(currentState.repoPath);

    emit(GitReady(
      status: _gitService.currentStatus,
      branches: _gitService.currentBranches,
      currentBranch: _gitService.currentBranch,
      stagedCount: _gitService.currentStatus.where((e) => e.isStaged).length,
      unstagedCount: _gitService.currentStatus.where((e) => !e.isStaged).length,
      repoPath: currentState.repoPath,
    ));
  }

  Future<void> _onStageFile(
    GitStageFile event,
    Emitter<GitState> emit,
  ) async {
    if (state is! GitReady) return;
    final currentState = state as GitReady;

    await _gitService.stageFile(currentState.repoPath, event.filePath);

    emit(GitReady(
      status: _gitService.currentStatus,
      branches: _gitService.currentBranches,
      currentBranch: _gitService.currentBranch,
      stagedCount: _gitService.currentStatus.where((e) => e.isStaged).length,
      unstagedCount: _gitService.currentStatus.where((e) => !e.isStaged).length,
      repoPath: currentState.repoPath,
    ));
  }

  Future<void> _onUnstageFile(
    GitUnstageFile event,
    Emitter<GitState> emit,
  ) async {
    if (state is! GitReady) return;
    final currentState = state as GitReady;

    await _gitService.unstageFile(currentState.repoPath, event.filePath);

    emit(GitReady(
      status: _gitService.currentStatus,
      branches: _gitService.currentBranches,
      currentBranch: _gitService.currentBranch,
      stagedCount: _gitService.currentStatus.where((e) => e.isStaged).length,
      unstagedCount: _gitService.currentStatus.where((e) => !e.isStaged).length,
      repoPath: currentState.repoPath,
    ));
  }

  Future<void> _onCommit(
    GitCommit event,
    Emitter<GitState> emit,
  ) async {
    if (state is! GitReady) return;
    final currentState = state as GitReady;

    final success = await _gitService.commit(currentState.repoPath, event.message);

    if (success) {
      emit(GitReady(
        status: _gitService.currentStatus,
        branches: _gitService.currentBranches,
        currentBranch: _gitService.currentBranch,
        stagedCount: _gitService.currentStatus.where((e) => e.isStaged).length,
        unstagedCount: _gitService.currentStatus.where((e) => !e.isStaged).length,
        repoPath: currentState.repoPath,
        lastCommitMessage: 'Commit realizado com sucesso',
      ));
    }
  }

  Future<void> _onCheckout(
    GitCheckout event,
    Emitter<GitState> emit,
  ) async {
    if (state is! GitReady) return;
    final currentState = state as GitReady;

    await _gitService.checkout(currentState.repoPath, event.branchName);

    emit(GitReady(
      status: _gitService.currentStatus,
      branches: _gitService.currentBranches,
      currentBranch: _gitService.currentBranch,
      stagedCount: _gitService.currentStatus.where((e) => e.isStaged).length,
      unstagedCount: _gitService.currentStatus.where((e) => !e.isStaged).length,
      repoPath: currentState.repoPath,
    ));
  }

  Future<void> _onShowDiff(
    GitShowDiff event,
    Emitter<GitState> emit,
  ) async {
    if (state is! GitReady) return;
    final currentState = state as GitReady;

    await _gitService.getDiff(currentState.repoPath, staged: event.staged);

    emit(GitReady(
      status: _gitService.currentStatus,
      branches: _gitService.currentBranches,
      currentBranch: _gitService.currentBranch,
      stagedCount: _gitService.currentStatus.where((e) => e.isStaged).length,
      unstagedCount: _gitService.currentStatus.where((e) => !e.isStaged).length,
      repoPath: currentState.repoPath,
        diffContent: _gitService.diffSubject.value,
    ));
  }
}
