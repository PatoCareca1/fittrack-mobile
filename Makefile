.PHONY: help install run devices test build doctor clean guard-flutter

# Resolve o binário do flutter: usa o do PATH se existir; senão cai no SDK local
# (~/sdk/flutter — instalação padrão desta máquina). Sobrescreva se precisar:
#   make run FLUTTER=/caminho/para/flutter
FLUTTER ?= $(shell command -v flutter 2>/dev/null || echo $$HOME/sdk/flutter/bin/flutter)
DEVICE  ?=

guard-flutter:
	@command -v $(FLUTTER) >/dev/null 2>&1 || { \
	  echo "flutter não encontrado (FLUTTER=$(FLUTTER))."; \
	  echo "Instale o Flutter ou informe o caminho: make run FLUTTER=/caminho/para/flutter"; \
	  exit 1; }

help:
	@echo "FitTrack (mobile / Flutter) — comandos:"
	@echo "  make install    flutter pub get"
	@echo "  make run        flutter run (precisa de device/emulador conectado)"
	@echo "  make devices    Lista devices/emuladores disponíveis"
	@echo "  make test       flutter test"
	@echo "  make build      Build do APK (debug)"
	@echo "  make doctor     flutter doctor"
	@echo "  make clean      flutter clean"
	@echo ""
	@echo "  Variáveis: FLUTTER=<caminho do binário>  DEVICE=<id do device>"

install: guard-flutter
	$(FLUTTER) pub get

run: guard-flutter
	$(FLUTTER) run $(if $(DEVICE),-d $(DEVICE),)

devices: guard-flutter
	$(FLUTTER) devices

test: guard-flutter
	$(FLUTTER) test

build: guard-flutter
	$(FLUTTER) build apk --debug

doctor: guard-flutter
	$(FLUTTER) doctor

clean: guard-flutter
	$(FLUTTER) clean
