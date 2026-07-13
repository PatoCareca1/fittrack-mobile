.PHONY: help install run devices test build doctor clean guard-flutter reverse-ports

# Resolve o binário do flutter: usa o do PATH se existir; senão cai no SDK local
# (~/sdk/flutter — instalação padrão desta máquina). Sobrescreva se precisar:
#   make run FLUTTER=/caminho/para/flutter
FLUTTER ?= $(shell command -v flutter 2>/dev/null || echo $$HOME/sdk/flutter/bin/flutter)
ADB     ?= $(shell command -v adb 2>/dev/null || echo $$HOME/Android/Sdk/platform-tools/adb)
DEVICE  ?=

# Backend Django em localhost:8000 no host. Em device físico via USB, "reverse-ports"
# encaminha essa porta pelo cabo (adb reverse) para o device enxergar como localhost —
# funciona tanto em device físico quanto em emulador, então é o default seguro.
# Sobrescreva se o backend estiver em outra máquina/IP: make run API_BASE_URL=http://192.168.x.x:8000/api/v1
API_BASE_URL ?= http://localhost:8000/api/v1

guard-flutter:
	@command -v $(FLUTTER) >/dev/null 2>&1 || { \
	  echo "flutter não encontrado (FLUTTER=$(FLUTTER))."; \
	  echo "Instale o Flutter ou informe o caminho: make run FLUTTER=/caminho/para/flutter"; \
	  exit 1; }

help:
	@echo "FitTrack (mobile / Flutter) — comandos:"
	@echo "  make install    flutter pub get"
	@echo "  make run        flutter run (precisa de device/emulador conectado)"
	@echo "                  encaminha :8000 (backend) via adb reverse automaticamente"
	@echo "  make devices    Lista devices/emuladores disponíveis"
	@echo "  make test       flutter test"
	@echo "  make build      Build do APK (debug)"
	@echo "  make doctor     flutter doctor"
	@echo "  make clean      flutter clean"
	@echo ""
	@echo "  Variáveis: FLUTTER=<caminho>  DEVICE=<id do device>  API_BASE_URL=<url>"

install: guard-flutter
	$(FLUTTER) pub get

# Encaminha a porta do backend (8000) do host para o device via USB/adb, para que
# API_BASE_URL=http://localhost:... funcione tanto em device físico quanto emulador.
# "-" ignora falha (ex.: nenhum device físico conectado, só o Linux desktop).
reverse-ports:
	-$(ADB) $(if $(DEVICE),-s $(DEVICE),) reverse tcp:8000 tcp:8000 2>/dev/null

run: guard-flutter reverse-ports
	$(FLUTTER) run $(if $(DEVICE),-d $(DEVICE),) --dart-define=API_BASE_URL=$(API_BASE_URL)

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
