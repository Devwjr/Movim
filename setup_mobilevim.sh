#!/bin/bash

# ============================================
# Script de Setup Automático do MobileVim
# ============================================

set -e

echo "============================================"
echo "    MobileVim - Setup Automático"
echo "============================================"
echo ""

# Verificar se Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter não encontrado!"
    echo ""
    echo "Para instalar o Flutter:"
    echo "  Ubuntu: sudo snap install flutter --classic"
    echo "  Ou visite: https://docs.flutter.dev/get-started/install"
    echo ""
    exit 1
fi

echo "✅ Flutter encontrado"
echo ""

# Verificar diretório atual
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "📂 Diretório do projeto: $DIR"
echo ""

# Passo 1: Inicializar projeto Flutter
echo "🔧 Passo 1/6: Inicializando projeto Flutter..."
if [ ! -d "android/app/src/main/kotlin" ]; then
    flutter create . --org com.example --project-name mobilevim
    echo "✅ Projeto Flutter inicializado"
else
    echo "⏭️  Projeto já inicializado, pulando..."
fi
echo ""

# Passo 2: Instalar dependências
echo "🔧 Passo 2/6: Instalando dependências..."
flutter pub get
echo "✅ Dependências instaladas"
echo ""

# Passo 3: Gerar arquivos do build_runner
echo "🔧 Passo 3/6: Gerando arquivos (build_runner)..."
dart run build_runner build --delete-conflicting-outputs
echo "✅ Arquivos gerados"
echo ""

# Passo 4: Baixar fontes JetBrainsMono
echo "🔧 Passo 4/6: Baixando fonte JetBrainsMono..."
mkdir -p assets/fonts

if [ ! -f "assets/fonts/JetBrainsMono-Regular.ttf" ]; then
    # Verificar se wget existe
    if command -v wget &> /dev/null; then
        cd assets/fonts
        
        # Tentar baixar do GitHub releases
        echo "   Baixando do GitHub..."
        wget -q "https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip" -O jbmono.zip
        
        if [ -f "jbmono.zip" ]; then
            unzip -q jbmono.zip -d temp
            
            # Copiar arquivos necessários
            if [ -d "temp/fonts/ttf" ]; then
                cp temp/fonts/ttf/JetBrainsMono-Regular.ttf .
                cp temp/fonts/ttf/JetBrainsMono-Bold.ttf .
                cp temp/fonts/ttf/JetBrainsMono-Italic.ttf .
            else
                # Tentar estrutura diferente
                find temp -name "*.ttf" -exec cp {} . \;
            fi
            
            # Limpar
            rm -rf temp jbmono.zip
        fi
        
        cd ../..
        
        if [ -f "assets/fonts/JetBrainsMono-Regular.ttf" ]; then
            echo "✅ Fonte baixada com sucesso"
        else
            echo "⚠️  Não foi possível baixar automaticamente"
            echo ""
            echo "   Baixe manualmente de:"
            echo "   https://www.jetbrains.com/lp/mono/"
            echo ""
            echo "   E coloque os arquivos .ttf em:"
            echo "   assets/fonts/"
        fi
    else
        echo "⚠️  wget não encontrado"
        echo ""
        echo "   Baixe a fonte manualmente de:"
        echo "   https://www.jetbrains.com/lp/mono/"
    fi
else
    echo "⏭️  Fonte já existe, pulando..."
fi
echo ""

# Passo 5: Verificar dispositivos
echo "🔧 Passo 5/6: Verificando dispositivos..."
flutter devices
echo ""

# Passo 6: Rodar flutter doctor
echo "🔧 Passo 6/6: Verificando configurações..."
flutter doctor
echo ""

echo "============================================"
echo "    ✅ Setup Concluído!"
echo "============================================"
echo ""
echo "📋 Próximos passos:"
echo ""
echo "1. (Opcional) Configurar GitHub OAuth:"
echo "   - Acesse: https://github.com/settings/developers"
echo "   - Crie um OAuth App com callback: mobilevim://auth/callback"
echo "   - Edite: lib/core/constants/app_constants.dart"
echo ""
echo "2. Conecte um dispositivo Android ou inicie um emulador"
echo ""
echo "3. Para rodar o app:"
echo "   cd $DIR"
echo "   flutter run"
echo ""
echo "4. Para build de release:"
echo "   flutter build apk --release"
echo ""
echo "============================================"
echo "MobileVim IDE - Codando como um ninja! 📱⚡"
echo "============================================"
