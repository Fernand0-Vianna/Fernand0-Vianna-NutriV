#!/bin/bash

# Este script constrói o APK de produção do NutriVision.

# Para ambientes: prod, dev
FLAVOR="prod"
# Arquivo de entrada principal
TARGET_FILE="lib/main.dart" # Se você usar main_dev.dart e main_prod.dart, ajuste aqui

echo "Iniciando build do APK para ambiente: $FLAVOR"

# Limpa o projeto Flutter
flutter clean

# Obtém as dependências
flutter pub get

# Constrói o APK assinado para produção
# Certifique-se de que seu arquivo key.properties e o keystore estão configurados para o build de produção.
# Veja: https://docs.flutter.dev/deployment/android#build-an-apk-or-app-bundle
flutter build apk --release \
  --flavor $FLAVOR \
  --target $TARGET_FILE \
  --dart-define=FLAVOR=$FLAVOR

if [ $? -eq 0 ]; then
  echo "Build do APK de $FLAVOR concluído com sucesso!"
  echo "O APK pode ser encontrado em: build/app/outputs/flutter-apk/app-${FLAVOR}-release.apk"
else
  echo "Erro no build do APK de $FLAVOR."
  exit 1
fi
