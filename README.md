# FreelaHub

Quadro de vagas freelance. **Empresas** publicam vagas pelo painel web e **freelancers** navegam, se candidatam e acompanham o status pelo app.

> Projeto de demonstração construído ao vivo durante a minha talk no **Sertão Tech 2026**, em **Parnaíba, Piauí** — mini curso *"O Kit do Freelancer Ágil"*. O escopo é propositalmente fechado: o que está em [`docs/`](docs) é o que existe.

## Como funciona

1. A empresa entra no painel, cria uma vaga e a publica.
2. O freelancer abre o app, busca e filtra vagas, vê o detalhe e se candidata com uma mensagem e um valor proposto.
3. A empresa avalia a candidatura no painel (`em análise` → `aprovada` ou `recusada`).
4. O freelancer vê o novo status no app, puxando a lista para atualizar.

## Telas do app

<p>
  <img src="FreelaHub%20%E2%80%94%20Telas%20do%20App-png/2%20%C2%B7%20Login.png" width="150" alt="Login">
  <img src="FreelaHub%20%E2%80%94%20Telas%20do%20App-png/4%20%C2%B7%20Vagas.png" width="150" alt="Vagas">
  <img src="FreelaHub%20%E2%80%94%20Telas%20do%20App-png/5%20%C2%B7%20Detalhe%20da%20vaga.png" width="150" alt="Detalhe da vaga">
  <img src="FreelaHub%20%E2%80%94%20Telas%20do%20App-png/8%20%C2%B7%20Perfil.png" width="150" alt="Perfil">
</p>

As oito telas e o design system estão em [`FreelaHub — Telas do App-png`](<FreelaHub — Telas do App-png>).

## Estrutura

```
freela-hub/
├── backend/   Laravel 13 + Filament 5 + Sanctum (base: filakitv5)
├── mobile/    Flutter, Clean Architecture + BLoC (base: base_clean_arch_bloc)
├── docs/      produto, arquitetura, modelo de dados, API, telas e ondas
└── CLAUDE.md  guia para o Claude Code
```

Um único projeto Laravel serve os dois painéis (`/admin` e `/empresa`) e a API (`/api`).

## Stack

| Parte | Tecnologias |
|---|---|
| Backend | PHP, Laravel, FilamentPHP, Sanctum, Pest/PHPUnit |
| App | Flutter, flutter_bloc, get_it, go_router, dio, result_dart |
| Banco | SQLite por padrão; MySQL opcional via `.env` |

## Rodando o backend

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
touch database/database.sqlite
php artisan migrate --seed
composer dev
```

- Painel da empresa: `http://localhost:8000/empresa`
- Painel do admin: `http://localhost:8000/admin`
- API: `http://localhost:8000/api` (contrato em [`docs/API.md`](docs/API.md), chamadas de exemplo em [`docs/api.http`](docs/api.http))

Para usar MySQL, ajuste `DB_CONNECTION` e as variáveis `DB_*` no `.env` antes do `migrate`.

### Dados de demonstração

O seeder cria 8 categorias, cerca de 20 vagas e estes usuários, todos com a senha `password`:

| Perfil | E-mail | Onde entra |
|---|---|---|
| Admin | `admin@freelahub.test` | `/admin` |
| Empresa | `empresa1@freelahub.test`, `empresa2@freelahub.test` | `/empresa` |
| Freelancer | `freela@freelahub.test` | app (API) |

### Testes

```bash
php artisan test
vendor/bin/pint   # formatação
```

## Rodando o app

```bash
cd mobile
flutter pub get
flutter run --dart-define=API_URL=http://10.0.2.2:8000/api   # emulador Android
flutter run --dart-define=API_URL=http://localhost:8000/api  # simulador iOS
```

Em um celular físico, use o IP da sua máquina na rede e suba o backend com `php artisan serve --host=0.0.0.0`.

```bash
flutter test
flutter analyze
```

## Regras de negócio

- **R1** — só vagas `abertas` aparecem na API e aceitam candidatura.
- **R2** — um freelancer só se candidata uma vez por vaga.
- **R3** — só `freelancer` se candida pela API; empresa e admin usam os painéis.
- **R4** — a empresa só enxerga e edita as próprias vagas e as candidaturas delas.
- **R5** — `enviada → em_analise → aprovada | recusada`; status final é definitivo.
- **R6** — o freelancer só retira a candidatura enquanto ela está `enviada`.
- **R7** — `valor_proposto` é opcional e, se informado, maior que zero.
- **R8** — encerrar uma vaga não apaga as candidaturas.

## Fora do escopo

Upload de arquivos, pagamentos, chat, notificações push, cadastro de empresa pela API, login social e internacionalização.

## Documentação

- [`docs/PRODUCT.md`](docs/PRODUCT.md) — visão, personas e regras
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — estrutura e padrões
- [`docs/DATA-MODEL.md`](docs/DATA-MODEL.md) — tabelas, enums e seeders
- [`docs/API.md`](docs/API.md) — contrato dos endpoints
- [`docs/SCREENS.md`](docs/SCREENS.md) — telas e design tokens
- [`docs/WAVES.md`](docs/WAVES.md) — ordem de execução da demo

## Autor

**Rodrigo Castro** — [@tecrodrigocastro](https://github.com/tecrodrigocastro)
