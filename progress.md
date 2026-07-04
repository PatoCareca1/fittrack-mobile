# Progress — fittrack-mobile

Última atualização: 2026-07-04

## Papel deste repo

App mobile Android (Flutter) do FitTrack. Ver `README.md` local e o README raiz em
`../fittrack-frontend/README.md`. Backend Django em `../fittrack-backend`.
**Escopo da demo em andamento: ver `MVP.md`.**

## O que já está pronto

**Ambiente rodando ponta a ponta em celular físico real** (2026-07-04) — máquina de
dev não tinha Flutter/Android SDK nem KVM habilitado (BIOS com SVM/AMD-V desligado,
sem `/dev/kvm`, então **emulador não é opção nesta máquina** até habilitar na BIOS).
Ambiente montado do zero: Flutter + Android SDK cmdline-tools via `pacman`/AUR
(`flutter-bin`, `android-sdk-cmdline-tools-latest`), JDK 17 (Gradle/AGP do template
atual não suporta JDK mais novo), `android-udev` para o `adb` funcionar sem root.
App rodado no celular (Galaxy S24+) via **Wireless debugging** (adb pair/connect por
Wi-Fi) — sem cabo USB, útil porque o notebook não tem porta USB-C compatível com o
cabo disponível. Passo a passo completo nos READMEs (backend e mobile, seção
"Rodando"). Validado pelo usuário direto no celular.

**MVP demo funcional ponta a ponta contra a API real** (2026-07-03) — cadastro →
dados físicos (meta calórica calculada) → dieta real (refeições, busca TACO,
quantidades, mark-done diário) → treinos reais (criação com biblioteca de 57
exercícios, execução com sessão/log-set/finish, navegação entre exercícios) →
evolução real (medições + sessões). Fluxo completo validado no emulador com
usuária nova ("Ana": 2670 kcal calculadas, refeição de 192 kcal marcada, treino
com tonelagem 120kg registrado).

Infra:
- Camada de dados por feature (`features/*/data.dart`): repositories + providers
  Riverpod que reagem a login/logout.
- `ApiClient` com refresh de JWT **single-flight** e persistência do refresh token
  rotacionado (backend usa ROTATE_REFRESH_TOKENS + blacklist — vários 401
  simultâneos compartilham uma renovação; falha de rede não desloga).
- Telas fora do MVP (profissional, chat, plano atribuído, explorar templates)
  preservadas em `features/`, sem rota.
- 4 testes de widget com providers sobrescritos (dados fake) — `flutter test` e
  `flutter analyze` limpos.

## O que falta / decisões pendentes

1. **Offline-first (README 5.4 — regra crítica)**: sessão de treino ainda é estado
   em memória (risco aceito na demo — ver MVP.md). Hive + connectivity_plus +
   `resume_pending_session` entram depois da demo.
2. **Alimento customizado**: endpoint existe (`POST /diet/foods/`), UI de criação
   ainda não exposta na busca.
3. **Fora da demo** (telas prontas, sem rota): vínculo profissional, plano
   atribuído, chat, explorar templates. Reordenar exercícios (drag & drop) não
   implementado.
4. **Pacotes do README ainda não adicionados**: freezed/riverpod_generator, hive,
   fl_chart, firebase_messaging, flutter_local_notifications, connectivity_plus,
   sentry_flutter, image_picker, permission_handler.
5. Reset de senha e login Google são só UI.
6. Cobertura de testes mínima de 50% (RNF07) — 4 testes de widget hoje.
7. Erro de auth fica na tela ao navegar login↔cadastro (estado compartilhado do
   AuthController — limpar ao trocar de tela).
8. Distribuição da demo: para testers fora da rede local (ou pra não depender do PC
   ligado), falta subir o backend hospedado e gerar APK com a URL pública. Opção
   recomendada para teste (grátis, sem cartão): **Render.com** (web service + Postgres
   free — web dorme após ~15min inativo, cold start ~30-50s; Postgres free expira em
   90 dias). Alternativa: Fly.io (cota free maior, config mais manual via `fly.toml`).

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
