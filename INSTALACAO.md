# 🚀 Guia Completo de Instalação - MobileVim

## 📋 Pré-requisitos

### 1. Instalar Flutter

#### Método 1: Snap (Ubuntu/Debian)
```bash
sudo snap install flutter --classic
```

#### Método 2: Download Manual
```bash
# Acesse https://docs.flutter.dev/get-started/install
# Ou use git:
cd ~
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/flutter/bin"
```

#### Verificar instalação
```bash
flutter doctor
```

**Resolva todas as dependências que o `flutter doctor` indicar!**

### 2. Instalar Android Studio (opcional mas recomendado)
```bash
# Ubuntu:
sudo snap install android-studio --classic
```

Ou baixe de: https://developer.android.com/studio

---

## 📂 Passo a Passo

### Passo 1: Navegar até o projeto
```bash
cd ~/Documentos/mobilevim
```

### Passo 2: Inicializar o projeto Flutter (Gera arquivos Android/iOS)
```bash
flutter create .
```

**Este comando é ESSENCIAL** - ele gera:
- `android/` completo com arquivos Gradle
- `ios/` (se precisar)
- Arquivos de configuração do Flutter

### Passo 3: Instalar dependências
```bash
flutter pub get
```

### Passo 4: Gerar arquivos do build_runner
```bash
dart run build_runner build --delete-conflicting-outputs
```

Isso gera:
- `app_router.gr.dart` (rotas)
- Arquivos `.g.dart` (json_serializable, freezed)

### Passo 5: Baixar fonte JetBrainsMono

Opção 1: Automaticamente (criar script)
```bash
mkdir -p assets/fonts
cd assets/fonts

# Baixar do GitHub
wget https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
unzip JetBrainsMono-2.304.zip

# Copiar os arquivos necessários
cp fonts/ttf/JetBrainsMono-Regular.ttf .
cp fonts/ttf/JetBrainsMono-Bold.ttf .
cp fonts/ttf/JetBrainsMono-Italic.ttf .

# Limpar
rm -rf fonts JetBrainsMono-2.304.zip
```

Opção 2: Manualmente
1. Acesse: https://www.jetbrains.com/lp/mono/
2. Baixe a fonte
3. Extraia os arquivos `.ttf` para `assets/fonts/`

### Passo 6: Configurar GitHub OAuth (opcional para login)

1. Acesse: https://github.com/settings/developers
2. Clique em **"New OAuth App"**
3. Preencha:
   - **Application name**: `MobileVim`
   - **Homepage URL**: `http://localhost`
   - **Authorization callback URL**: `mobilevim://auth/callback`
4. Clique em **"Register application"**
5. Copie o **Client ID**
6. Clique em **"Generate a new client secret"** e copie

7. Edite `lib/core/constants/app_constants.dart`:
```dart
static const String githubClientId = 'SEU_CLIENT_ID_AQUI';
static const String githubClientSecret = 'SEU_CLIENT_SECRET_AQUI';
```

### Passo 7: Conectar dispositivo ou emulador

#### Opção A: Emulador Android
1. Abra Android Studio
2. AVD Manager → Create Virtual Device
3. Escolha um dispositivo (Pixel recomendado)
4. Baixe uma imagem do sistema (API 21+)
5. Inicie o emulador

#### Opção B: Dispositivo físico
1. Ative **"Opções do Desenvolvedor"** no celular
2. Ative **"Depuração USB"**
3. Conecte via USB
4. Permita a depuração no celular

Verificar dispositivos conectados:
```bash
flutter devices
```

### Passo 8: Rodar o app
```bash
flutter run
```

---

## 🎯 Build para Release

### Gerar APK
```bash
flutter build apk --release
```

O APK estará em: `build/app/outputs/flutter-apk/app-release.apk`

### Gerar App Bundle (para Play Store)
```bash
flutter build appbundle
```

---

## ❌ Problemas Comuns e Soluções

### Problema 1: "Unable to locate Android SDK"
**Solução:**
```bash
flutter config --android-sdk ~/Android/Sdk
# Ou onde estiver seu SDK
```

### Problema 2: Licenças do Android não aceitas
**Solução:**
```bash
flutter doctor --android-licenses
```
Aceite todas as licenças (digite `y` para cada).

### Problema 3: Permissões de armazenamento no Android 11+
O app já está configurado com:
- `MANAGE_EXTERNAL_STORAGE` (Android 11+)
- `READ_EXTERNAL_STORAGE` / `WRITE_EXTERNAL_STORAGE` (Android 10-)

Na primeira execução, o app vai pedir permissão.

### Problema 4: Fontes não carregando
**Verifique:**
1. Arquivos existem em `assets/fonts/`
2. Nomes corretos no `pubspec.yaml`
3. Rode `flutter clean && flutter pub get`

### Problema 5: build_runner conflitos
**Solução:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Problema 6: Gradle version mismatch
**Solução:**
Edite `android/build.gradle` e verifique as versões:
```gradle
classpath 'com.android.tools.build:gradle:8.1.0'
classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0"
```

---

## 📱 Permissões Android

O app solicita as seguintes permissões:

| Permissão | Motivo |
|-----------|--------|
| `INTERNET` | Autenticação GitHub, APIs |
| `READ_EXTERNAL_STORAGE` | Ler arquivos do projeto |
| `WRITE_EXTERNAL_STORAGE` | Salvar arquivos editados |
| `MANAGE_EXTERNAL_STORAGE` | Acesso completo (Android 11+) |
| `CAMERA` | Funcionalidades futuras |
| `RECORD_AUDIO` | Funcionalidades futuras |
| `VIBRATE` | Feedback háptico |
| `WAKE_LOCK` | Manter tela ligada |

---

## 🔧 Modo Desenvolvedor

### Hot Reload
Enquanto o app está rodando, pressione:
- `r` no terminal para Hot Reload
- `R` no terminal para Hot Restart

### Debug
```bash
flutter run --debug
```

### Verificar performance
```bash
flutter run --profile
```

---

## 📊 Estrutura após instalação

```
mobilevim/
├── android/                    # Gerado pelo flutter create
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/com/example/mobilevim/
│   │       └── res/
│   ├── build.gradle
│   └── settings.gradle
├── assets/
│   ├── fonts/                   # Adicione as fontes aqui
│   │   ├── JetBrainsMono-Regular.ttf
│   │   ├── JetBrainsMono-Bold.ttf
│   │   └── JetBrainsMono-Italic.ttf
│   ├── icons/
│   ├── themes/
│   └── templates/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   ├── features/
│   └── widgets/
├── test/
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

---

## ✅ Checklist de Instalação

- [ ] Flutter instalado e no PATH
- [ ] `flutter doctor` sem erros
- [ ] `flutter create .` executado
- [ ] `flutter pub get` executado
- [ ] `dart run build_runner build` executado
- [ ] Fonte JetBrainsMono em `assets/fonts/`
- [ ] (Opcional) GitHub OAuth configurado
- [ ] Dispositivo/emulador conectado
- [ ] `flutter run` executado com sucesso

---

## 🆘 Suporte

Se tiver problemas:

1. Verifique o `flutter doctor`
2. Tente: `flutter clean && flutter pub get && flutter run`
3. Verifique se todas as permissões foram concedidas
4. Reinicie o emulador/dispositivo

---

**Boa codificação!** 🎉📱

Agora você tem uma IDE Vim completa no seu celular Android.
