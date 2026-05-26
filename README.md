# MobileVim

Uma IDE movel com edicao estilo Vim para Android, construida com Flutter. Focada em desenvolvimento web e backend diretamente do celular.

## Funcionalidades

### Motor de Editor Vim
- Sistema completo de modos: Normal, Insert, Visual, Visual Line, Visual Block, Command
- Navegacao do cursor: `h/j/k/l`, `w/b/e`, `0/$/^/gg/G`
- Manipulacao de texto: inserir, deletar, yank (`yy`), colar (`p`/`P`), unir linhas (`J`)
- Pilha de Undo/Redo (1000 entradas por buffer)
- Busca com `/pattern` e `?pattern`, navegacao `n`/`N`, suporte a regex
- Comandos Ex: `:w`, `:q`, `:wq`, `:e!`, `:new`, `:split`, `:vsplit`, `:{linha}`, `:marks`, `:help`, `:set`
- Marcadores (marks) e lista de saltos com `Ctrl+O`/`Ctrl+I`
- Indentacao com `<`/`>`, alternar maiuscula/minuscula com `~`
- Repetir ultima alteracao com `.`
- Multiplos buffers com abas
- Barra de status com modo, nome do arquivo, tipo, encoding, linha:coluna, percentual de scroll

### Syntax Highlighting
- 5 temas de editor: Dracula, One Dark, Nord, Tokyo Night, Gruvbox Dark
- Highlight para multiplas linguagens via `flutter_highlight`
- Numeros de linha na gutter

### Explorador de Arquivos
- Navegar por diretorios
- Operacoes: criar, deletar, renomear, copiar, mover
- Ordenar por nome, tamanho, data, tipo
- Alternar arquivos ocultos
- Deteccao de tipo de arquivo e icones

### Terminal Integrado
- Comandos internos: `cd`, `pwd`, `ls`, `clear`, `echo`, `cat`, `mkdir`, `rm`, `touch`, `cp`, `mv`
- Execucao de processos externos
- Historico de comandos com setas
- Prompt customizado com usuario, host e diretorio

### Integracao Git
- Deteccao de repositorio
- Status de arquivos (staged/unstaged)
- Stage/unstage de arquivos
- Commit com mensagem
- Exibicao de branch
- Visualizacao de diffs
- Historico de commits

### Autenticacao GitHub
- Login com GitHub OAuth2
- Obter perfil e repositorios do usuario
- Navegar pelo conteudo de repositorios
- Ler conteudo de arquivos
- Criar Gists

### Templates de Projetos
Scaffold de projetos a partir de 17 templates:

Frontend:
- React + Vite, Vue.js + Vite, Next.js, Svelte + Vite, Angular, Astro

Backend:
- Express.js, FastAPI, NestJS, Django, Flask, Go + Gin, Laravel, Spring Boot

Mobile:
- Flutter, React Native

Fullstack:
- Remix

### Sistema de Plugins
- 14 plugins nativos (temas, syntax, terminal, git, etc.)
- Ativar/desativar por plugin
- Arquitetura extensivel

### Configuracoes
- Modo de tema: Claro, Escuro, Sistema
- Tamanho da fonte (8-32px) com JetBrainsMono
- Tamanho da tab (2, 4, 6, 8)
- Expandir tabs (espacos vs tabs)
- Alternadores: numeros de linha, quebra de linha, auto save, mostrar invisiveis, mostrar minimapa
- Selecao de tema do editor
- Restaurar padroes

### Onboarding
- Fluxo de boas-vindas em 3 etapas
- Gerenciamento de permissao de armazenamento Android (API 21-33+)
- Experiencia de primeiro uso

## Arquitetura

```
Clean Architecture + BLoC Pattern

lib/
  main.dart                   Ponto de entrada, DI, MultiBlocProvider
  app.dart                    MaterialApp, tema, roteamento
  core/                       Infraestrutura compartilhada
    constants/                Constantes do app, mapas de linguagem/arquivo
    themes/                   ThemeData, paletas de cores, cores do editor
    utils/                    Funcoes auxiliares
    services/                 Servicos: Git, GitHub, Terminal, Permissao
    data/repositories/        FileRepository
    routes/                   Geracao de rotas nomeadas
  features/                   Modulos de dominio (por feature)
    {feature}/
      data/                   Implementacoes
      domain/                 Entidades, interfaces de repositorio
      presentation/           BLoCs, Paginas, Widgets
  widgets/                    Widgets reutilizaveis compartilhados
    vim_keyboard/             Teclado virtual Vim customizado
    status_bar/               Barra de status do editor
    tab_bar/                  Abas de buffers
```

### Gerenciamento de Estado
- `flutter_bloc` com um BLoC por feature
- Estados imutaveis com Equatable
- MultiBlocProvider no nivel raiz

### Injecao de Dependencia
- `get_it` para servicos (singletons)
- Injecao por construtor para BLoCs

### Tecnologias
- Flutter 3.x / Dart
- flutter_bloc (gerenciamento de estado)
- get_it (injecao de dependencia)
- shared_preferences / flutter_secure_storage (persistencia)
- flutter_highlight / highlight (syntax highlighting)
- xterm (emulacao de terminal)
- http (API GitHub)
- uni_links (deep linking para callback OAuth)

## Pre-requisitos

- Flutter SDK (>= 3.0.0)
- Android SDK (API 21+, target 34+)
- Dispositivo Android ou emulador
- Conta GitHub (para funcionalidades OAuth)

## Instalacao

```bash
# Navegar ate o projeto
cd ~/Documentos/mobilevim

# Instalar dependencias
flutter pub get

# Executar em dispositivo conectado
flutter run

# Build APK de release
flutter build apk --release
```

### Configuracao do GitHub OAuth

1. Acesse GitHub Developer Settings > OAuth Apps > New OAuth App
2. Application name: `MobileVim`
3. Homepage URL: `http://localhost`
4. Authorization callback URL: `mobilevim://auth/callback`
5. Copie o Client ID e Client Secret
6. Edite `lib/core/constants/app_constants.dart`:

```dart
static const String githubClientId = 'SEU_CLIENT_ID';
static const String githubClientSecret = 'SEU_CLIENT_SECRET';
```

### Instalacao no Waydroid

```bash
# Build o APK
flutter build apk --release --target-platform android-x64

# Inicie o Waydroid e instale
waydroid app install build/app/outputs/flutter-apk/app-release.apk
```

## Permissoes Android

| Permissao | Motivo |
|---|---|
| INTERNET | API GitHub, autenticacao |
| READ_EXTERNAL_STORAGE | Ler arquivos do projeto |
| WRITE_EXTERNAL_STORAGE | Salvar arquivos editados |
| MANAGE_EXTERNAL_STORAGE | Acesso completo a arquivos (Android 11+) |
| FOREGROUND_SERVICE | Tarefas em segundo plano |
| WAKE_LOCK | Manter tela ligada durante programacao |
| VIBRATE | Feedback haptico |
| RECEIVE_BOOT_COMPLETED | Configuracao na inicializacao |

## Comandos Vim

### Modos
- `Esc` - Modo Normal
- `i` / `I` - Insert antes do cursor / inicio da linha
- `a` / `A` - Insert depois do cursor / fim da linha
- `o` / `O` - Abrir linha abaixo / acima
- `v` / `V` - Modo Visual / Visual Line
- `:` - Modo Command

### Navegacao
- `h/j/k/l` - Esquerda/Baixo/Cima/Direita
- `w/b/e` - Proxima palavra / Palavra anterior / Final da palavra
- `0` / `$` - Inicio da linha / Fim da linha
- `gg` / `G` - Primeira linha / Ultima linha
- `Ctrl+O` / `Ctrl+I` - Voltar / Avancar no historico de saltos

### Edicao
- `dd` - Deletar linha
- `yy` - Yank (copiar) linha
- `p` / `P` - Colar depois / antes do cursor
- `u` / `Ctrl+r` - Desfazer / Refazer
- `x` - Deletar caractere
- `J` - Unir linhas
- `.` - Repetir ultima alteracao
- `~` - Alternar maiuscula/minuscula
- `<` / `>` - Indentar / Dedentar

### Busca
- `/pattern` - Buscar para frente
- `?pattern` - Buscar para tras
- `n` / `N` - Proxima / Anterior ocorrencia

### Comandos Ex
- `:w` - Salvar
- `:w <caminho>` - Salvar como
- `:q` / `:q!` - Sair / Forcar saida
- `:wq` - Salvar e sair
- `:e!` - Recarregar arquivo
- `:new` - Novo buffer
- `:split` / `:vsplit` - Split view (placeholder UI)
- `:{n}` - Ir para linha n
- `:marks` - Mostrar marcadores
- `:set <opcao>` - Definir opcao
- `:help` - Ajuda

## Estrutura do Projeto

```
mobilevim/
  lib/                          ~10.000+ linhas em 47 arquivos
    main.dart
    app.dart
    core/
      constants/
      themes/
      utils/
      services/
      data/repositories/
      routes/
    features/
      editor/                   Motor Vim (~3.000 linhas)
      auth/                     GitHub OAuth (~300 linhas)
      git/                      Integracao Git (~600 linhas)
      settings/                 Preferencias (~500 linhas)
      plugins/                  Sistema de plugins (~400 linhas)
      templates/                Scaffold de projetos (~900 linhas)
      explorer/                 Navegador de arquivos (~700 linhas)
      terminal/                 Shell (~600 linhas)
      onboarding/               Experiencia de primeiro uso
    widgets/                    UI compartilhada (~750 linhas)
      vim_keyboard/
      status_bar/
      tab_bar/
  assets/
    fonts/                      JetBrainsMono (Regular, Bold, Italic)
    themes/                     Arquivos de tema (a serem adicionados)
    templates/                  Arquivos de template (a serem adicionados)
    plugins/                    Arquivos de plugin (a serem adicionados)
  android/
  test/
```

## Roadmap

- Integracao LSP (Language Server Protocol)
- Debugger integrado
- Git diff e stage na interface
- Snippets inteligentes
- Integracao com Docker
- Suporte a multi-cursor
- Minimapa do codigo
- Split view (horizontal/vertical)
- Sincronizacao de configuracoes via GitHub Gist
- Marketplace de plugins da comunidade
- Internacionalizacao (i18n)
- Arquivos de tema de syntax highlighting a partir de assets
- Integracao xterm no terminal

## Problemas Conhecidos

- Comportamento do teclado fisico varia por dispositivo
- Alguns comandos Vim avancados nao implementados
- Terminal limitado a comandos basicos
- Diretorios de assets declarados mas nao populados em disco

## Licenca

MIT License
