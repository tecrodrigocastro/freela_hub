# WAVES — ordem de execução

Cada onda = 1 issue no Linear (ou grupo de sub-issues), termina com testes verdes, commit e tag. O tempo é um alvo para o mini curso (2h); o código é gerado por IA, o que consome tempo é revisar e testar.

## Onda 0 — Setup (~10 min) · tag `onda-0`
- Criar repo com `backend/`, `app/`, `docs/`, `CLAUDE.md`.
- `backend/`: Laravel + Filament (base filakitv5) rodando com SQLite.
- `app/`: Flutter a partir de base_clean_arch_bloc rodando no emulador.
- **Aceite:** `composer dev` abre o painel; `flutter run` abre o app; `php artisan test` e `flutter test` passam.

## Onda 1 — Modelo e painel da Empresa (~25 min) · tag `onda-1`
- Migrations, models, enums, seeders conforme `DATA-MODEL.md`.
- Campo `role` em `users`; `canAccessPanel` por role; painéis `/admin` e `/empresa`.
- Filament Empresa: `VagaResource` (CRUD escopado à empresa logada, Action `PublicarVaga`/`EncerrarVaga`) e `CandidaturaResource` (lista por vaga, mudar status com `AtualizarStatusCandidatura`, regra R5).
- Filament Admin: `CategoriaResource`, `UserResource`.
- Policies R4.
- **Aceite:** login como `empresa1` mostra só as vagas dela; admin gerencia categorias; testes de Policy e Actions passam.

## Onda 2 — API (~20 min) · tag `onda-2`
- Sanctum; rotas e controllers de `API.md`; Form Requests e API Resources.
- Regras R1, R2, R3, R6, R7 em Actions + testes Feature por endpoint.
- **Aceite:** todos os endpoints respondem como em `API.md`; coleção de chamadas (`.http` ou Postman) executa o fluxo completo registro → vaga → candidatura → retirada.

## Onda 3 — App: auth e lista de vagas (~30 min) · tag `onda-3`
- Core: dio + interceptor, tema com tokens de `SCREENS.md`, storage seguro.
- Features `auth` (Splash, Login, Cadastro) e `vagas` (Lista com busca/filtros/paginação, Detalhe).
- go_router com guard e bottom navigation.
- **Aceite:** criar conta, logar, ver lista com dados do seeder, filtrar, abrir detalhe; sessão persiste ao reabrir; testes de BLoC das duas features.

## Onda 4 — App: candidaturas e perfil (~20 min) · tag `onda-4`
- Tela Candidatar-se, aba Candidaturas (com retirar), aba Perfil.
- Estados vazio/erro/loading em todas as telas.
- **Aceite:** o fluxo completo funciona ponta a ponta: empresa muda status no painel e freelancer vê no app após pull-to-refresh.

## Folga (~15 min)
Ajustes, dúvidas do público e demo final. Se sobrar tempo: mostrar o Remote Pi/Cockpit controlando a sessão a partir do celular.

## Tasks para o Linear
Uma issue por onda, título `[Onda N] ...`, descrição = bullets acima, critérios de aceite como checklist, label `freelahub`. Prompt sugerido para o Claude Code em cada onda:

> Leia CLAUDE.md e docs/. Execute a Onda N descrita em docs/WAVES.md. Siga os padrões de ARCHITECTURE.md, não saia do escopo, rode os testes e só então faça o commit e a tag `onda-N`.
