# DATA MODEL

## Enums (string)
| Enum | Valores |
|---|---|
| Role | `admin`, `empresa`, `freelancer` |
| Modalidade | `remoto`, `hibrido`, `presencial` |
| TipoPagamento | `fixo`, `hora` |
| StatusVaga | `aberta`, `encerrada` |
| StatusCandidatura | `enviada`, `em_analise`, `aprovada`, `recusada` |

## Tabelas

### users
| Coluna | Tipo | Notas |
|---|---|---|
| id | bigint PK | |
| name | string | |
| email | string unique | |
| password | string | hash |
| role | string | enum Role, default `freelancer` |
| empresa_nome | string null | só para `empresa` |
| bio | text null | só para `freelancer` |
| timestamps | | |

### categorias
| id | bigint PK |
|---|---|
| nome | string |
| slug | string unique |

### vagas
| Coluna | Tipo | Notas |
|---|---|---|
| id | bigint PK | |
| user_id | FK users | empresa dona (cascade) |
| categoria_id | FK categorias | |
| titulo | string(120) | |
| descricao | text | |
| modalidade | string | enum Modalidade |
| tipo_pagamento | string | enum TipoPagamento |
| valor_min | decimal(10,2) null | |
| valor_max | decimal(10,2) null | |
| prazo_dias | unsigned smallint null | duração estimada do trabalho |
| status | string | enum StatusVaga, default `aberta` |
| publicada_em | timestamp null | preenchido ao publicar |
| timestamps | | |

Índices: `status`, `categoria_id`, `modalidade`. Busca textual simples com `LIKE` em `titulo` e `descricao`.

### candidaturas
| Coluna | Tipo | Notas |
|---|---|---|
| id | bigint PK | |
| vaga_id | FK vagas | cascade |
| user_id | FK users | freelancer |
| mensagem | text | 10–1000 caracteres |
| valor_proposto | decimal(10,2) null | > 0 se informado |
| status | string | enum StatusCandidatura, default `enviada` |
| timestamps | | |

Unique: `(vaga_id, user_id)`.

## Relacionamentos
- `User(empresa) hasMany Vaga`
- `User(freelancer) hasMany Candidatura`
- `Categoria hasMany Vaga`
- `Vaga belongsTo User (empresa), belongsTo Categoria, hasMany Candidatura`
- `Candidatura belongsTo Vaga, belongsTo User (freelancer)`

## Seeders
- `CategoriaSeeder` — as 8 categorias de `PRODUCT.md`.
- `UserSeeder` — admin, 2 empresas, 1 freelancer (credenciais em `PRODUCT.md`).
- `VagaSeeder` — ~20 vagas realistas em pt-BR, valores em BRL, mistura de modalidades; 2 delas `encerrada`.
- `CandidaturaSeeder` — 3 candidaturas do freelancer demo em status diferentes (`enviada`, `em_analise`, `aprovada`), para a tela de candidaturas nascer preenchida.
