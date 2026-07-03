# MVP Demo — FitTrack

Objetivo: versão funcional para um grupo seleto usar por ~1 semana e levantar
melhorias/erros. Definido em 2026-07-03.

## O que está DENTRO (tudo funcionando contra a API real)

| Fluxo | Detalhe |
|---|---|
| Conta | Cadastro (tipo Usuário), login, logout, sessão persistente com refresh de JWT (rotação single-flight) |
| Onboarding | Pós-cadastro → Dados Físicos (peso, altura, idade, sexo, objetivo, atividade) → **meta calórica e macros calculadas no backend** (Mifflin-St Jeor, RN01–RN03) |
| Dieta | Criar refeições (nome/horário), buscar alimento (seed TACO ~38 itens), adicionar por quantidade em gramas, remover, excluir refeição, **marcar/desmarcar como feita por dia**, totais de kcal/macros por refeição e do dia |
| Treino | Criar treino com biblioteca de **57 exercícios** (filtro por grupo muscular + busca), séries/reps/carga/descanso por exercício, excluir treino |
| Execução | Sessão real (start-session), navegação **anterior/próximo**, carga/reps editáveis por série, ✓ grava set na API (log-set), descanso automático com o tempo do exercício, comentário, finalizar (finish) |
| Evolução | Gráfico de peso/gordura/massa magra com medições reais + lista de sessões concluídas (data, duração, tonelagem) |
| Medição | Registrar peso (só peso basta) ou bioimpedância completa; recalcula a meta calórica |
| Dashboard | Saudação real, treino do dia, anel de kcal consumidas vs. meta, barras de macros, refeições do dia com estado, atalhos |

## O que está FORA (adiado, telas preservadas sem rota)

- Vínculo profissional, plano atribuído, chat (backend pronto p/ vínculo; UI sai da demo)
- Explorar rotinas/templates, reordenar exercícios (drag & drop)
- Reset de senha, login Google, push, offline-first (Hive), Sentry

## Riscos aceitos na demo

- Sessão de treino é estado em memória: crash/fechar o app no meio perde as séries
  não sincronizadas (offline-first entra depois — README raiz 5.4).
- Base TACO é seed parcial (~38 alimentos). Alimento que faltar: usuário pode
  cadastrar o próprio (botão de criar alimento ainda não exposto na UI — workaround:
  pedir para os testers anotarem alimentos que faltaram).
- 1 plano alimentar por usuário (auto-criado "Meu plano").

## Como distribuir para os testers

```bash
cd fittrack-mobile
flutter build apk --debug --dart-define=API_BASE_URL=http://SEU_IP:8000/api/v1
# enviar build/app/outputs/flutter-apk/app-debug.apk
```

Backend precisa estar acessível pelos testers (mesma rede: `runserver 0.0.0.0:8000`;
internet: subir em Railway/Render — pendência para demo remota).

## Decisões tomadas nesta fase (para revisar com o time)

1. `body_fat_pct` virou **opcional** no `BodyMetric` — pesagem simples só exige peso.
   RN14 (peso + % gordura) segue valendo para o fluxo de bioimpedância. Confirmar
   com Amanda.
2. Idade na UI → convertida para `birth_date` aproximada (dia/mês atuais). Trocar por
   date picker se incomodar.
3. Endpoints granulares de refeição (`POST /diet/meals/`, `POST /diet/meals/{id}/items/`,
   `DELETE /diet/meal-items/{id}`) criados para edições não recriarem refeições
   (o PATCH aninhado apagava os logs do dia em cascata).
4. Sessão: `finish` agora aceita `notes`; serializer expõe `workout_name`.
