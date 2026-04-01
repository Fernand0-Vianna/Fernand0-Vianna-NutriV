#!/bin/bash

# Este script constrói o IPA de produção do NutriVision.

# Para ambientes: prod, dev
FLAVOR="prod"
# Arquivo de entrada principal
TARGET_FILE="lib/main.dart"

echo "Iniciando build do IPA para ambiente: $FLAVOR"

# Limpa o projeto Flutter
flutter clean

# Obtém as dependências
flutter pub get

# Constrói o IPA para produção
# Este comando requer que você tenha um certificado de desenvolvedor e um perfil de provisionamento configurados no Xcode.
# Veja: https://docs.flutter.dev/deployment/ios#build-and-release-for-ios
flutter build ipa --release \
  --flavor $FLAVOR \
  --target $TARGET_FILE \
  --dart-define=FLAVOR=$FLAVOR

if [ $? -eq 0 ]; then
  echo "Build do IPA de $FLAVOR concluído com sucesso!"
  echo "O IPA pode ser encontrado em: build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app"
  echo "Você pode fazer upload para o App Store Connect usando o Xcode Organizer."
else
  echo "Erro no build do IPA de $FLAVOR."
  exit 1
fi
