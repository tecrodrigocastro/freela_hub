# API — contrato

Base: `/api` · JSON · Autenticação: `Authorization: Bearer <token>` (Sanctum). Cabeçalho `Accept: application/json` sempre.

Erros: 401 (sem token), 403 (sem permissão), 404, 422 (validação):
```json
{ "message": "The email field is required.", "errors": { "email": ["The email field is required."] } }
```
`message` é um texto legível gerado pelo Laravel (pode trazer "(and N more errors)"); o app deve usar `errors` por campo. Qualquer erro em `/api/*` responde JSON, mesmo sem `Accept`.

## Auth

### POST /auth/register  (público)
Cria sempre um usuário `freelancer`.
```json
// request
{ "name": "Ana Souza", "email": "ana@email.com", "password": "secret123", "password_confirmation": "secret123" }
// 201
{ "token": "1|abc...", "user": { "id": 4, "name": "Ana Souza", "email": "ana@email.com", "role": "freelancer", "bio": null } }
```

### POST /auth/login  (público)
```json
// request
{ "email": "freela@freelahub.test", "password": "password" }
// 200
{ "token": "2|def...", "user": { "id": 4, "name": "...", "email": "...", "role": "freelancer", "bio": null } }
```
Credenciais inválidas → 422 com erro em `email`. Usuário que não é `freelancer` → 403.

### POST /auth/logout  (auth) → 204
### GET /me  (auth) → `{ "data": { user } }`
### PUT /me  (auth)
```json
{ "name": "Ana S.", "bio": "Dev Flutter, 3 anos" }   // 200 { "data": { user } }
```

## Categorias

### GET /categorias  (auth)
```json
{ "data": [ { "id": 1, "nome": "Desenvolvimento Web", "slug": "desenvolvimento-web" } ] }
```

## Vagas

### GET /vagas  (auth)
Somente `aberta`, mais recentes primeiro, 10 por página.
Query: `q` (texto), `categoria_id`, `modalidade` (`remoto|hibrido|presencial`), `page`.
```json
{
  "data": [
    {
      "id": 12,
      "titulo": "App Flutter para clínica",
      "empresa": "Clínica Vida",
      "categoria": { "id": 2, "nome": "Desenvolvimento Mobile" },
      "modalidade": "remoto",
      "tipo_pagamento": "fixo",
      "valor_min": 3000.0,
      "valor_max": 5000.0,
      "prazo_dias": 45,
      "publicada_em": "2026-10-01T14:00:00Z",
      "ja_candidatou": false
    }
  ],
  "links": { "next": "http://.../api/vagas?page=2", "prev": null },
  "meta": { "current_page": 1, "last_page": 3, "total": 24 }
}
```

### GET /vagas/{id}  (auth)
Mesmos campos da lista, mais `descricao` (texto completo) e `total_candidaturas`. Vaga `encerrada` → 404.

## Candidaturas (freelancer logado)

### POST /vagas/{id}/candidaturas  (auth, role freelancer)
```json
// request
{ "mensagem": "Tenho 3 anos de Flutter e já fiz apps de saúde.", "valor_proposto": 4200.0 }
// 201
{ "data": { "id": 7, "vaga": { "id": 12, "titulo": "..." }, "mensagem": "...", "valor_proposto": 4200.0, "status": "enviada", "created_at": "..." } }
```
Regras: vaga `aberta` (senão 404), sem candidatura prévia (senão 422 com `errors.vaga`), `mensagem` 10–1000 chars, `valor_proposto` opcional > 0.

### GET /candidaturas  (auth)
Do usuário logado, mais recentes primeiro, 10 por página. Query opcional: `status`.
```json
{ "data": [ { "id": 7, "vaga": { "id": 12, "titulo": "App Flutter para clínica", "empresa": "Clínica Vida" }, "valor_proposto": 4200.0, "status": "em_analise", "created_at": "..." } ], "links": {}, "meta": {} }
```

### GET /candidaturas/{id}  (auth)
Detalhe com `mensagem` completa e a vaga resumida. Candidatura de outro usuário → 403.

### DELETE /candidaturas/{id}  (auth) → 204
Só se `status = enviada` (senão 422 `errors.status`) e se for do usuário (senão 403).

## Rotas (resumo)
| Método | Rota | Auth |
|---|---|---|
| POST | /auth/register | não |
| POST | /auth/login | não |
| POST | /auth/logout | sim |
| GET/PUT | /me | sim |
| GET | /categorias | sim |
| GET | /vagas | sim |
| GET | /vagas/{id} | sim |
| POST | /vagas/{id}/candidaturas | sim |
| GET | /candidaturas | sim |
| GET/DELETE | /candidaturas/{id} | sim |
