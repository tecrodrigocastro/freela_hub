# ARCHITECTURE

## Visão geral
```
 Flutter app ──HTTP/JSON (Bearer Sanctum)──▶ Laravel /api ──▶ MySQL/SQLite
                                               ▲
 Painel Empresa / Admin (Filament) ────────────┘ (mesmo projeto, mesmas Actions)
```
Um único projeto Laravel serve: painel `/empresa`, painel `/admin` e a API `/api`.

## Backend (`backend/`) — Laravel 13 + Filament 5
Base sugerida: **filakitv5** (monolito com multi-painel e multi-auth). Se preferir começar do zero, `laravel new` + `composer require filament/filament`.

```
app/
├── Actions/
│   ├── Vagas/            PublicarVaga, EncerrarVaga
│   └── Candidaturas/     CriarCandidatura, RetirarCandidatura, AtualizarStatusCandidatura
├── Enums/                Role, Modalidade, TipoPagamento, StatusVaga, StatusCandidatura
├── Filament/
│   ├── Admin/            Resources: Categoria, User
│   └── Empresa/          Resources: Vaga, Candidatura (escopo da empresa logada)
├── Http/
│   ├── Controllers/Api/  AuthController, VagaController, CategoriaController, CandidaturaController
│   ├── Requests/         RegisterRequest, LoginRequest, CandidaturaRequest
│   └── Resources/        UserResource, VagaResource, CategoriaResource, CandidaturaResource
├── Models/               User, Categoria, Vaga, Candidatura
└── Policies/             VagaPolicy, CandidaturaPolicy
routes/api.php
```

### Padrões obrigatórios
- **Actions**: classe com um método `handle()`, chamada por controller e por Filament. Nada de regra de negócio em controller.
- **Form Request** para toda entrada da API; **API Resource** para toda saída.
- **Policies** registradas e usadas (`authorize`) em API e Filament.
- **Enums** PHP 8.x backed (string) com cast no model.
- Paginação padrão da API: 10 itens (`?page=`).
- Erros de validação: 422 no formato padrão Laravel (`message` + `errors`).
- Testes Feature (Pest ou PHPUnit) para cada endpoint e para as regras R1–R8.

## App (`app/`) — Flutter
Base: **base_clean_arch_bloc** (Clean Architecture + BLoC, get_it, go_router, dio, result_dart).

```
lib/
├── core/            dio client (interceptor com token), erros, tema (tokens de SCREENS.md), storage
├── features/
│   ├── auth/            referência de estrutura (data / domain / presentation)
│   ├── vagas/           lista, filtros, detalhe
│   ├── candidaturas/    enviar, listar, retirar
│   └── perfil/
├── shared/          widgets reutilizáveis (VagaCard, StatusChip, EmptyState, ErrorState)
├── dependency_injector.dart
└── router.dart
```

### Padrões obrigatórios
- Camadas: `presentation (page + bloc) → domain (entity, repository, usecase) → data (datasource, model, repository impl)`.
- Retorno de usecases/repos: `Result<T, AppFailure>`.
- BLoC com estados explícitos: `initial / loading / success / empty / failure`.
- Token Sanctum em `flutter_secure_storage`; interceptor do dio injeta `Authorization: Bearer`; 401 → limpa sessão e vai para login.
- URL da API via `--dart-define=API_URL`.
- Navegação: go_router com guard de autenticação; bottom navigation com 3 abas (Vagas, Candidaturas, Perfil).

## Autenticação
- API: Sanctum com tokens pessoais (`createToken`). Login retorna `token`.
- Painéis: guard web padrão do Filament. `User.role` decide o acesso (`canAccessPanel`): `admin → /admin`, `empresa → /empresa`; `freelancer` não acessa painel.

## Ambiente
SQLite por padrão (zero configuração para o curso); MySQL opcional via `.env`.
