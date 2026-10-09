# FreelaHub — guia para o Claude Code

Quadro de vagas freelance. Empresas publicam vagas pelo painel **FilamentPHP**; freelancers navegam, se candidatam e acompanham o status pelo app **Flutter**. O mesmo projeto Laravel serve o admin (Filament) e a API (Sanctum).

Projeto de demonstração do mini curso "O Kit do Freelancer Ágil" (Sertão Tech 2026). Escopo **fechado**: não adicione funcionalidades que não estejam em `docs/`.

## Leia antes de codar
1. `docs/PRODUCT.md` — o que é, para quem, regras de negócio, o que está fora do escopo
2. `docs/ARCHITECTURE.md` — estrutura de pastas e padrões obrigatórios
3. `docs/DATA-MODEL.md` — tabelas, enums, seeders
4. `docs/API.md` — contrato dos endpoints (fonte da verdade para backend e app)
5. `docs/SCREENS.md` — telas do app, estados e endpoints usados
6. `docs/WAVES.md` — ordem de execução, critérios de aceite e tags

## Layout do repositório
```
freelahub/
├── backend/   Laravel 13 + Filament 5 + Sanctum (base: filakitv5)
├── app/       Flutter, Clean Architecture + BLoC (base: base_clean_arch_bloc)
├── docs/
└── CLAUDE.md
```

## Comandos
Backend (`cd backend`):
- `composer install && cp .env.example .env && php artisan key:generate`
- `php artisan migrate --seed`
- `composer dev` — servidor, fila e logs
- `php artisan test`
- `vendor/bin/pint` — formatação

App (`cd app`):
- `flutter pub get`
- `flutter run --dart-define=API_URL=http://10.0.2.2:8000/api` (emulador Android; no iOS use `http://localhost:8000/api`)
- `flutter test` · `flutter analyze`
- `mason make feature` — gera uma feature nova (quando o brick estiver instalado)

## Regras
- Termos de domínio em português (`Vaga`, `Candidatura`, `Categoria`); código, nomes de classe e métodos em inglês só quando for convenção do framework.
- Backend: lógica de negócio em **Actions** (`app/Actions`), nunca em controller ou resource do Filament. Validação em **Form Requests**, saída em **API Resources**, autorização em **Policies**.
- Contrato da API é `docs/API.md`. Se precisar mudar, atualize o doc no mesmo commit.
- App: Clean Architecture + BLoC. Use a feature `auth` como referência de estrutura (data/domain/presentation). Retornos com `Result` (result_dart). Injeção em `dependency_injector.dart`, rotas com go_router.
- Telas seguem `docs/SCREENS.md` e o design tokens ali definidos. Não invente telas.
- Cada onda termina com testes passando, commit e tag `onda-N`.
- Commits pequenos, mensagem no imperativo, em português.

## Fora do escopo (não fazer)
Upload de arquivos, pagamentos, chat, notificações push, cadastro de empresa via API (empresas são criadas no admin/seeder), login social, internacionalização.
