# fittrack-mobile

App mobile Android (Flutter/Dart) do FitTrack — acompanhamento integrado de dieta e
treino, dark mode por padrão, pt-BR.

**Contexto completo do produto** (visão, stack, design system, modelo de dados, regras
de negócio RN01–RN14, RNFs): ver `../fittrack-frontend/README.md` — é o README de
referência do projeto inteiro. Fonte de verdade em caso de conflito:
`FitTrack_Documento_de_Requisitos_v1.pdf` e `FitTrack_Decisoes_v2.pdf`.

**Protótipo visual aprovado:**
`../fittrack-frontend/Protótipo FitTrack mobile/FitTrack.dc.html` — fonte de verdade
para layout, hierarquia visual e microcopy de cada tela.

**Estado atual, pendências e decisões:** ver `progress.md` (ler no início de qualquer
sessão de continuação).

## Stack

- Flutter 3.32 / Dart 3.8 — Android-first (API 26+)
- Riverpod 2.x (state management — decisão definitiva)
- go_router (rotas declarativas + guard de autenticação)
- dio (HTTP com injeção de JWT e refresh automático)
- flutter_secure_storage (tokens JWT)
- google_fonts (Inter + Space Grotesk, tokens da seção 6 do README raiz)

## Estrutura

Feature-first (README raiz, seção 5.2):

```
lib/
  core/
    config/       # env (API_BASE_URL via --dart-define)
    network/      # ApiClient: dio + JWT refresh automático
    storage/      # TokenStorage (flutter_secure_storage)
    router/       # go_router: splash, guard de auth, shell com 5 tabs
    theme/        # app_colors.dart (paleta exata) + app_theme.dart (dark)
    widgets/      # PillButton, FtCard, FtTag, MuscleIcon, ScreenHeader...
  features/
    auth/         # onboarding, login (API real), cadastro, recuperação
    dashboard/    # Início: CTA treino, anel de calorias, macros, refeições
    workouts/     # Meus Treinos, Explorar Rotinas, Detalhe do Treino
    workout_session/  # Execução: timer de sessão/descanso, séries
    diet/         # Plano de Refeições, Buscar Alimento, Detalhe de refeição
    body_metrics/ # Evolução (gráficos), Bioimpedância
    profile/      # Perfil, Configurações, Dados Físicos
    professional/ # Meus Profissionais, Aceitar Convite, Plano Atribuído
    chat/         # Chat aluno-profissional
  mock/           # mock_data.dart — dados do protótipo (ver progress.md)
```

## Rodando

### 0. Pré-requisito: o backend precisa estar no ar

O login/cadastro do app falham sem a API. No repo `../fittrack-backend`:

```bash
docker compose up -d db                  # 1. sobe o PostgreSQL (porta 5432)
.venv/bin/python manage.py migrate       # 2. aplica migrações (só na 1ª vez / quando houver novas)
.venv/bin/python manage.py runserver 0.0.0.0:8000   # 3. sobe a API
```

Use `0.0.0.0:8000` (e não só `runserver`): assim a API aceita conexões de fora do
notebook — necessário para o **celular físico**. Para usar apenas o emulador,
`runserver` simples (localhost) basta. `ALLOWED_HOSTS` já está liberado em
`config/settings/dev.py` para dev.

### 1. Preparar o app (1ª vez)

```bash
flutter pub get       # baixa dependências
flutter test          # sanity check — 4 smoke tests devem passar
```

### 2. Rodar no emulador Android

```bash
flutter emulators                        # lista emuladores disponíveis
flutter emulators --launch <id>          # sobe um (ou abra pelo Android Studio)
flutter run                              # compila e instala no emulador
```

Não precisa configurar URL: o default `http://10.0.2.2:8000/api/v1` já aponta para
o `localhost` do notebook visto de dentro do emulador.

### 3. Rodar no celular físico (USB)

1. **No celular**: ative *Opções do desenvolvedor* (toque 7× em "Número da versão"
   em Configurações → Sobre o telefone) e ligue **Depuração USB**.
2. **Conecte o cabo USB** e aceite o prompt "Permitir depuração USB?" na tela.
3. **Celular e notebook na mesma rede Wi-Fi** (a API é servida pelo notebook).
4. Descubra o IP do notebook na rede: `ip -4 addr | grep inet` (ex.: `10.17.0.241`).
5. Confirme que o backend está rodando com `0.0.0.0:8000` (passo 0).
6. Rode apontando a API para o IP do notebook:

```bash
flutter devices                          # o celular deve aparecer na lista
flutter run --dart-define=API_BASE_URL=http://SEU_IP:8000/api/v1
# exemplo: flutter run --dart-define=API_BASE_URL=http://10.17.0.241:8000/api/v1
```

Notas:
- HTTP sem TLS é permitido **só no build de debug**
  (`android/app/src/debug/AndroidManifest.xml` → `usesCleartextTraffic`). Release
  exigirá HTTPS.
- Se o celular não aparecer em `flutter devices`: confira o modo de conexão USB
  (usar "Transferência de arquivos"/PTP, não "Só carregar") e rode `adb devices`.
- Firewall do notebook precisa aceitar entrada na porta 8000
  (`sudo ufw allow 8000` se usar ufw).

### 4. Alternativa sem cabo: instalar o APK

```bash
flutter build apk --debug --dart-define=API_BASE_URL=http://SEU_IP:8000/api/v1
```

Envie `build/app/outputs/flutter-apk/app-debug.apk` ao celular (Google Drive,
`adb install`, etc.) e instale (permita "fontes desconhecidas"). Importante: como a
URL é embutida no build, **gere o APK já com o `--dart-define` correto** — sem ele o
app procura a API em `10.0.2.2`, que só existe no emulador.

### Comandos úteis

```bash
flutter analyze        # lint estático
flutter test           # smoke tests de widgets
r / R (no flutter run) # hot reload / hot restart
```
