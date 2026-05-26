import 'dart:io';
import 'package:rxdart/rxdart.dart';

class TerminalService {
  final _outputSubject = BehaviorSubject<String>();
  final _historySubject = BehaviorSubject<List<String>>();
  final List<String> _history = [];
  int _historyIndex = -1;
  
  Process? _currentProcess;
  String _currentDirectory = '/';
  String _currentOutput = '';

  Stream<String> get outputStream => _outputSubject.stream;
  Stream<List<String>> get historyStream => _historySubject.stream;
  List<String> get history => List.unmodifiable(_history);
  String get currentDirectory => _currentDirectory;
  String get currentOutput => _currentOutput;

  TerminalService() {
    _initTerminal();
  }

  void _initTerminal() {
    _currentOutput = 'MobileVim Terminal v1.0.0\n';
    _currentOutput += 'Digite "help" para ver os comandos disponíveis\n\n';
    _outputSubject.add(_currentOutput);
    _updateCurrentDirectory();
  }

  Future<void> _updateCurrentDirectory() async {
    try {
      final directory = Directory.current;
      _currentDirectory = directory.path;
    } catch (e) {
      _currentDirectory = '/';
    }
  }

  Future<void> executeCommand(String command) async {
    if (command.trim().isEmpty) {
      _addToOutput('\n');
      return;
    }

    _history.add(command);
    _historyIndex = _history.length;
    _historySubject.add(List.unmodifiable(_history));

    _addToOutput('${getPrompt()}$command\n');

    final parts = command.trim().split(' ');
    final cmd = parts[0].toLowerCase();
    final args = parts.sublist(1);

    if (_isBuiltInCommand(cmd)) {
      await _executeBuiltInCommand(cmd, args);
    } else {
      await _executeExternalCommand(cmd, args);
    }
  }

  bool _isBuiltInCommand(String cmd) {
    const builtIns = [
      'cd',
      'pwd',
      'ls',
      'clear',
      'cls',
      'history',
      'help',
      'exit',
      'echo',
      'cat',
      'mkdir',
      'rm',
      'rmdir',
      'touch',
      'cp',
      'mv',
    ];
    return builtIns.contains(cmd);
  }

  Future<void> _executeBuiltInCommand(String cmd, List<String> args) async {
    switch (cmd) {
      case 'cd':
        await _changeDirectory(args);
        break;
      case 'pwd':
        _addToOutput('$currentDirectory\n');
        break;
      case 'ls':
        await _listDirectory(args);
        break;
      case 'clear':
      case 'cls':
        _clearTerminal();
        break;
      case 'history':
        _showHistory();
        break;
      case 'help':
        _showHelp();
        break;
      case 'exit':
        _addToOutput('Saindo do terminal...\n');
        break;
      case 'echo':
        _addToOutput('${args.join(' ')}\n');
        break;
      case 'cat':
        await _showFileContent(args);
        break;
      case 'mkdir':
        await _makeDirectory(args);
        break;
      case 'rm':
        await _removeFile(args);
        break;
      case 'rmdir':
        await _removeDirectory(args);
        break;
      case 'touch':
        await _touchFile(args);
        break;
      case 'cp':
        await _copyFile(args);
        break;
      case 'mv':
        await _moveFile(args);
        break;
      default:
        _addToOutput('Comando não reconhecido: $cmd\n');
    }
  }

  Future<void> _executeExternalCommand(String cmd, List<String> args) async {
    try {
      final process = await Process.start(
        cmd,
        args,
        workingDirectory: currentDirectory,
        environment: Platform.environment,
      );

      _currentProcess = process;

      process.stdout.transform(const SystemEncoding().decoder).listen((data) {
        _addToOutput(data);
      });

      process.stderr.transform(const SystemEncoding().decoder).listen((data) {
        _addToOutput(data);
      });

      final exitCode = await process.exitCode;
      _currentProcess = null;
      
      if (exitCode != 0) {
        _addToOutput('Processo terminado com código de saída: $exitCode\n');
      }
    } catch (e) {
      _addToOutput('Erro ao executar comando: $e\n');
    }
  }

  Future<void> _changeDirectory(List<String> args) async {
    if (args.isEmpty) {
      try {
        final home = Platform.environment['HOME'] ??
            Platform.environment['USERPROFILE'] ??
            '/';
        Directory.current = home;
        _currentDirectory = home;
      } catch (e) {
        _addToOutput('cd: erro ao acessar diretório home\n');
      }
      return;
    }

    try {
      final target = args[0];
      final newDir = target.startsWith('/')
          ? Directory(target)
          : Directory('${Directory.current.path}/$target');
      
      if (await newDir.exists()) {
        Directory.current = newDir.path;
        _currentDirectory = newDir.path;
      } else {
        _addToOutput('cd: diretório não existe: $target\n');
      }
    } catch (e) {
      _addToOutput('cd: erro ao mudar diretório: $e\n');
    }
  }

  Future<void> _listDirectory(List<String> args) async {
    try {
      final dir = Directory.current;
      final entities = dir.listSync();
      
      final dirs = <String>[];
      final files = <String>[];
      
      for (final entity in entities) {
        final name = entity.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
        if (name.startsWith('.') && !args.contains('-a')) continue;
        
        if (entity is Directory) {
          dirs.add(name);
        } else {
          files.add(name);
        }
      }
      
      dirs.sort();
      files.sort();
      
      for (final d in dirs) {
        _addToOutput('\x1B[34m$d/\x1B[0m  ');
      }
      for (final f in files) {
        _addToOutput('$f  ');
      }
      _addToOutput('\n');
    } catch (e) {
      _addToOutput('ls: erro ao listar diretório: $e\n');
    }
  }

  Future<void> _showFileContent(List<String> args) async {
    if (args.isEmpty) {
      _addToOutput('cat: uso: cat <arquivo>\n');
      return;
    }

    try {
      final file = File(args[0]);
      if (await file.exists()) {
        final content = await file.readAsString();
        _addToOutput('$content\n');
      } else {
        _addToOutput('cat: arquivo não existe: ${args[0]}\n');
      }
    } catch (e) {
      _addToOutput('cat: erro ao ler arquivo: $e\n');
    }
  }

  Future<void> _makeDirectory(List<String> args) async {
    if (args.isEmpty) {
      _addToOutput('mkdir: uso: mkdir <nome>\n');
      return;
    }

    try {
      final dir = Directory(args[0]);
      if (!await dir.exists()) {
        await dir.create();
        _addToOutput('Diretório criado: ${args[0]}\n');
      } else {
        _addToOutput('mkdir: diretório já existe: ${args[0]}\n');
      }
    } catch (e) {
      _addToOutput('mkdir: erro ao criar diretório: $e\n');
    }
  }

  Future<void> _removeFile(List<String> args) async {
    if (args.isEmpty) {
      _addToOutput('rm: uso: rm <arquivo>\n');
      return;
    }

    try {
      final file = File(args[0]);
      if (await file.exists()) {
        await file.delete();
        _addToOutput('Arquivo removido: ${args[0]}\n');
      } else {
        _addToOutput('rm: arquivo não existe: ${args[0]}\n');
      }
    } catch (e) {
      _addToOutput('rm: erro ao remover arquivo: $e\n');
    }
  }

  Future<void> _removeDirectory(List<String> args) async {
    if (args.isEmpty) {
      _addToOutput('rmdir: uso: rmdir <diretório>\n');
      return;
    }

    try {
      final dir = Directory(args[0]);
      if (await dir.exists()) {
        await dir.delete();
        _addToOutput('Diretório removido: ${args[0]}\n');
      } else {
        _addToOutput('rmdir: diretório não existe: ${args[0]}\n');
      }
    } catch (e) {
      _addToOutput('rmdir: erro ao remover diretório: $e\n');
    }
  }

  Future<void> _touchFile(List<String> args) async {
    if (args.isEmpty) {
      _addToOutput('touch: uso: touch <arquivo>\n');
      return;
    }

    try {
      final file = File(args[0]);
      if (!await file.exists()) {
        await file.create();
        _addToOutput('Arquivo criado: ${args[0]}\n');
      } else {
        final now = DateTime.now();
        await file.setLastModified(now);
      }
    } catch (e) {
      _addToOutput('touch: erro ao criar arquivo: $e\n');
    }
  }

  Future<void> _copyFile(List<String> args) async {
    if (args.length < 2) {
      _addToOutput('cp: uso: cp <origem> <destino>\n');
      return;
    }

    try {
      final source = File(args[0]);
      if (await source.exists()) {
        await source.copy(args[1]);
        _addToOutput('Arquivo copiado: ${args[0]} -> ${args[1]}\n');
      } else {
        _addToOutput('cp: origem não existe: ${args[0]}\n');
      }
    } catch (e) {
      _addToOutput('cp: erro ao copiar arquivo: $e\n');
    }
  }

  Future<void> _moveFile(List<String> args) async {
    if (args.length < 2) {
      _addToOutput('mv: uso: mv <origem> <destino>\n');
      return;
    }

    try {
      final source = File(args[0]);
      if (await source.exists()) {
        await source.rename(args[1]);
        _addToOutput('Arquivo movido: ${args[0]} -> ${args[1]}\n');
      } else {
        _addToOutput('mv: origem não existe: ${args[0]}\n');
      }
    } catch (e) {
      _addToOutput('mv: erro ao mover arquivo: $e\n');
    }
  }

  void _clearTerminal() {
    _currentOutput = '';
    _outputSubject.add(_currentOutput);
  }

  void _showHistory() {
    for (var i = 0; i < _history.length; i++) {
      _addToOutput('${i + 1}  ${_history[i]}\n');
    }
  }

  void _showHelp() {
    final helpText = '''
Comandos integrados do MobileVim Terminal:

  Navegação:
    cd <dir>     - Mudar diretório
    pwd          - Mostrar diretório atual
    ls           - Listar arquivos

  Arquivos:
    cat <file>   - Mostrar conteúdo do arquivo
    touch <file> - Criar arquivo vazio
    mkdir <dir>  - Criar diretório
    rm <file>    - Remover arquivo
    rmdir <dir>  - Remover diretório
    cp <o> <d>   - Copiar arquivo
    mv <o> <d>   - Mover arquivo

  Utilitários:
    echo <text>  - Imprimir texto
    clear        - Limpar terminal
    history      - Mostrar histórico
    help         - Esta ajuda
    exit         - Sair

Comandos externos do sistema também estão disponíveis.
''';
    _addToOutput(helpText);
  }

  String getPrompt() {
    final user = Platform.environment['USER'] ??
        Platform.environment['USERNAME'] ?? 'user';
    final dirParts = _currentDirectory.split(Platform.pathSeparator);
    final currentDirName = dirParts.last.isEmpty ? '/' : dirParts.last;
    
    return '$user@mobilevim:$currentDirName\$ ';
  }

  void _addToOutput(String text) {
    _currentOutput += text;
    _outputSubject.add(_currentOutput);
  }

  String? getPreviousHistory() {
    if (_history.isEmpty) return null;
    if (_historyIndex > 0) {
      _historyIndex--;
      return _history[_historyIndex];
    }
    return _history.isNotEmpty ? _history[0] : null;
  }

  String? getNextHistory() {
    if (_history.isEmpty) return null;
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      return _history[_historyIndex];
    }
    _historyIndex = _history.length;
    return '';
  }

  void cancelCurrentProcess() {
    _currentProcess?.kill();
    _currentProcess = null;
    _addToOutput('^C\n');
  }

  void dispose() {
    _currentProcess?.kill();
    _outputSubject.close();
    _historySubject.close();
  }
}
