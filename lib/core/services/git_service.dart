import 'dart:io';
import 'package:rxdart/rxdart.dart';

class GitBranch {
  final String name;
  final bool isCurrent;
  final bool isRemote;

  const GitBranch({
    required this.name,
    this.isCurrent = false,
    this.isRemote = false,
  });
}

class GitStatusEntry {
  final String path;
  final String status;
  final bool isStaged;

  const GitStatusEntry({
    required this.path,
    required this.status,
    this.isStaged = false,
  });

  String get statusLabel {
    switch (status) {
      case 'M':
        return 'Modificado';
      case 'A':
        return 'Adicionado';
      case 'D':
        return 'Deletado';
      case 'R':
        return 'Renomeado';
      case 'C':
        return 'Copiado';
      case 'U':
        return 'Atualizado';
      case '?':
        return 'Não rastreado';
      default:
        return status;
    }
  }

  String get shortStatus => status;
}

class GitService {
  final BehaviorSubject<List<GitStatusEntry>> _statusSubject =
      BehaviorSubject<List<GitStatusEntry>>.seeded([]);
  final BehaviorSubject<List<GitBranch>> _branchSubject =
      BehaviorSubject<List<GitBranch>>.seeded([]);
  final BehaviorSubject<String> _currentBranchSubject =
      BehaviorSubject<String>.seeded('unknown');
  final BehaviorSubject<String> _diffSubject =
      BehaviorSubject<String>.seeded('');
  final BehaviorSubject<bool> _isGitRepoSubject =
      BehaviorSubject<bool>.seeded(false);

  Stream<List<GitStatusEntry>> get statusStream => _statusSubject.stream;
  Stream<List<GitBranch>> get branchStream => _branchSubject.stream;
  Stream<String> get currentBranchStream => _currentBranchSubject.stream;
  Stream<String> get diffStream => _diffSubject.stream;
  BehaviorSubject<String> get diffSubject => _diffSubject;
  Stream<bool> get isGitRepoStream => _isGitRepoSubject.stream;

  List<GitStatusEntry> get currentStatus => _statusSubject.value;
  List<GitBranch> get currentBranches => _branchSubject.value;
  String get currentBranch => _currentBranchSubject.value;
  bool get isGitRepo => _isGitRepoSubject.value;

  Future<void> checkGitRepo(String path) async {
    try {
      final result = await Process.run('git', ['rev-parse', '--git-dir'],
          workingDirectory: path);
      _isGitRepoSubject.add(result.exitCode == 0);
    } catch (_) {
      _isGitRepoSubject.add(false);
    }
  }

  Future<void> getStatus(String path) async {
    try {
      final result = await Process.run('git', ['status', '--porcelain'],
          workingDirectory: path);
      if (result.exitCode == 0) {
        final entries = (result.stdout as String)
            .split('\n')
            .where((l) => l.trim().isNotEmpty)
            .map((line) {
          final staged = line[0].trim();
          final working = line[1].trim();
          final filePath = line.substring(3).trim();
          final status = working.isNotEmpty ? working : staged;
          return GitStatusEntry(
            path: filePath,
            status: status,
            isStaged: staged.isNotEmpty && working.isEmpty,
          );
        }).toList();
        _statusSubject.add(entries);
      }
    } catch (_) {}
  }

  Future<void> getBranches(String path) async {
    try {
      final result = await Process.run(
          'git', ['branch', '-a'],
          workingDirectory: path);
      if (result.exitCode == 0) {
        final branches = (result.stdout as String)
            .split('\n')
            .where((l) => l.trim().isNotEmpty)
            .map((line) {
          final isCurrent = line.startsWith('*');
          final name = line.replaceAll('*', '').trim();
          final isRemote = name.startsWith('remotes/');
          return GitBranch(
            name: isRemote ? name.replaceFirst('remotes/', '') : name,
            isCurrent: isCurrent,
            isRemote: isRemote,
          );
        }).toList();
        _branchSubject.add(branches);

        final current = branches.where((b) => b.isCurrent).firstOrNull;
        if (current != null) {
          _currentBranchSubject.add(current.name);
        }
      }
    } catch (_) {}
  }

  Future<void> getDiff(String path, {bool staged = false}) async {
    try {
      final args = ['diff'];
      if (staged) args.add('--cached');
      final result = await Process.run('git', args,
          workingDirectory: path);
      if (result.exitCode == 0) {
        _diffSubject.add(result.stdout as String);
      }
    } catch (_) {
      _diffSubject.add('');
    }
  }

  Future<bool> stageFile(String path, String filePath) async {
    try {
      final result = await Process.run('git', ['add', filePath],
          workingDirectory: path);
      if (result.exitCode == 0) {
        await getStatus(path);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unstageFile(String path, String filePath) async {
    try {
      final result = await Process.run('git', ['reset', 'HEAD', filePath],
          workingDirectory: path);
      if (result.exitCode == 0) {
        await getStatus(path);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> commit(String path, String message) async {
    try {
      final result = await Process.run(
          'git', ['commit', '-m', message],
          workingDirectory: path);
      if (result.exitCode == 0) {
        await getStatus(path);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkout(String path, String branch) async {
    try {
      final result = await Process.run('git', ['checkout', branch],
          workingDirectory: path);
      if (result.exitCode == 0) {
        await getBranches(path);
        await getStatus(path);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<String> getLog(String path, {int count = 10}) async {
    try {
      final result = await Process.run(
          'git', ['log', '--oneline', '-n', count.toString()],
          workingDirectory: path);
      if (result.exitCode == 0) {
        return result.stdout as String;
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  void dispose() {
    _statusSubject.close();
    _branchSubject.close();
    _currentBranchSubject.close();
    _diffSubject.close();
    _isGitRepoSubject.close();
  }
}
