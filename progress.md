# Progress — fittrack-mobile

Última atualização: 2026-07-02

## Papel deste repo

App mobile Android (Flutter) do FitTrack. Ver `README.md` local e o README raiz em
`../fittrack-frontend/README.md`. Backend Django em `../fittrack-backend`.

## O que já está pronto

Todas as **21 telas do protótipo aprovado** (`FitTrack.dc.html`) implementadas em
Flutter, fiéis ao layout/microcopy/tokens do design system:

| Área | Telas | Status |
|---|---|---|
| Auth | Splash · Onboarding (3 páginas) · Login · Cadastro (3 tipos de conta) · Recuperar senha | Prontas — login/cadastro ligados de verdade ao backend (`/auth/login/`, `/auth/register/`) |
| Início | Dashboard (CTA treino, anel kcal, macros, refeições, atalhos) | Pronta (mock) |
| Treino | Meus Treinos · Explorar Rotinas · Detalhe do Treino · Execução (timer sessão + descanso, séries, comentário) | Prontas (mock) |
| Dieta | Plano de Refeições · Buscar Alimento (TACO/OFF) · Detalhe de refeição | Prontas (mock) |
| Evolução | Gráfico peso/gordura/massa magra (CustomPainter) + sessões | Pronta (mock) |
| Perfil | Perfil · Configurações · Dados Físicos · Bioimpedância (+histórico) | Prontas (mock) |
| Profissional | Meus Profissionais · Aceitar Convite · Plano Atribuído (selo somente leitura, RN04/RN10) · Chat | Prontas (mock) |

Infra:
- Router go_router com **guard de autenticação** (splash → onboarding/login se sem
  token; telas do painel exigem sessão) e shell com bottom nav de 5 tabs.
- `ApiClient` (dio) com injeção de JWT e **refresh automático** em 401.
- Tokens em `flutter_secure_storage`.
- Tema dark com a paleta exata da seção 6 (Inter + Space Grotesk via google_fonts).
- 4 smoke tests de widget (`test/smoke_test.dart`) — `flutter test` e
  `flutter analyze` limpos.

## O que falta / decisões pendentes

1. **Dados reais**: só auth consome o backend. Endpoints de vínculo profissional
   (`/professional/links/accept/`, `/professional/assignments/`) passaram a existir
   em 2026-07-02 — as telas "Aceitar Convite" e "Plano Atribuído" são as primeiras
   candidatas à integração. Treinos, dieta, evolução, bioimpedância,
   profissionais e chat usam `lib/mock/mock_data.dart` (mesmo racional do painel web).
   Ao integrar, criar `data/domain` por feature mantendo os shapes do mock.
2. ~~Endpoint de cadastro~~ **Resolvido (2026-07-02)**: contrato validado contra o
   backend real — envia `{account_type, first_name, last_name, email, password}` e
   aproveita os tokens que o register já retorna (sem segundo login). Register e
   login testados via curl contra o Django + Postgres locais.
3. **Offline-first (README 5.4 — regra crítica)**: Hive + connectivity_plus +
   `resume_pending_session` ainda não implementados; a execução de treino hoje é
   estado em memória. Entra junto com a integração da API de sessões.
4. **Pacotes do README ainda não adicionados** (decisão consciente para a fase
   UI-first, adicionar quando a funcionalidade correspondente entrar):
   freezed/riverpod_generator (codegen — providers hoje são manuais, ainda Riverpod
   2.x), hive, fl_chart (gráfico atual é CustomPainter próprio, mesma decisão do
   web), firebase_messaging, flutter_local_notifications, connectivity_plus,
   sentry_flutter, image_picker, permission_handler.
5. **Reordenar exercícios (drag & drop)** na execução ainda não implementado.
6. **Recuperação de senha** é só UI (backend não tem endpoint de reset ainda).
7. **Login com Google** — botão presente (protótipo), sem implementação; não está nos
   PDFs como requisito de MVP, decidir se fica.
8. Cobertura de testes mínima de 50% (RNF07) — hoje só smoke tests.
9. ~~Build APK~~ **Resolvido**: `flutter build apk --debug` gera
   `build/app/outputs/flutter-apk/app-debug.apk` com sucesso (validado 2026-07-02).
   `flutter doctor` ainda aponta `cmdline-tools`/licenças como warning, sem bloquear.

## Decisões/simplificações tomadas

- **UI-first com mock**: prioridade era fechar a versão mobile (todas as telas
  navegáveis); integração de API é a fase seguinte, feature a feature.
- Riverpod manual (`Notifier`/`NotifierProvider`) sem codegen por enquanto — menos
  fricção de build_runner; migrar para `riverpod_generator` quando os models freezed
  entrarem.
- Gráfico de evolução em `CustomPainter` (mesmo visual do LineChart SVG do web) em vez
  de fl_chart — 1 gráfico simples não justifica a dependência ainda.
- Ícones de exercício: `MuscleIcon` (CustomPainter, elipse + linhas) seguindo a regra
  6.6 — nunca fotos.
- `API_BASE_URL` configurável via `--dart-define`; default `10.0.2.2:8000` (emulador).

## Como retomar

1. Ler este arquivo + README raiz (`../fittrack-frontend/README.md`).
2. `flutter pub get && flutter test` para validar o ambiente.
3. Próximo passo natural: (a) subir o backend e validar login/cadastro reais no
   emulador, ajustando o contrato de `/auth/register/`; ou (b) começar a integração
   de dados reais por `body_metrics` (endpoints `/me/body-metrics/` já existem no
   backend) e depois treinos/dieta.
