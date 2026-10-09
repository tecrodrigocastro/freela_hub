# SCREENS — app Flutter

Mobile (390×844). Tema claro, identidade do Sertão Tech 2026 (deserto).

**Referência visual (Claude Design):** https://claude.ai/artifact/NBQsMXxBVs59TSbmuorBeS — 8 artboards, um por tela abaixo. Texto desta doc e design devem andar juntos; em caso de dúvida de layout, o design manda, e o contrato de dados é `API.md`.

## Design tokens
| Token | Valor |
|---|---|
| ink (texto) | #4A2E1E |
| terra (primária) | #C2601D |
| gold (destaque) | #E8961E |
| cream (fundo) | #FBEFD3 |
| cream2 (superfície alt.) | #F3DFAE |
| card | #FCF3DC |
| dark | #2B1B10 |
| muted | #6B5738 |
| Títulos | Libre Baskerville |
| Corpo | Public Sans |
| Raio card | 16 · botão 12 · chip 999 |
| Espaçamento | múltiplos de 4 (16 de margem lateral) |

Status (chip): `enviada` muted/cream2 · `em_analise` gold · `aprovada` verde #4C7A34 · `recusada` vermelho #A63D2F.

## Navegação
Sem sessão: Splash → Login ⇄ Cadastro.
Com sessão: bottom navigation com 3 abas — **Vagas**, **Candidaturas**, **Perfil**. Detalhe da vaga e candidatar-se empilham sobre a aba Vagas.

## Telas

### 1. Splash
Logo/nome "FreelaHub", verifica token salvo. Token válido → Vagas; senão → Login.

### 2. Login
Campos e-mail e senha, botão "Entrar", link "Criar conta".
Estados: loading no botão, erro de credenciais inline, erro de rede com retry.
API: `POST /auth/login`.

### 3. Cadastro
Campos nome, e-mail, senha, confirmar senha, botão "Criar conta", link "Já tenho conta".
Estados: loading, erros de validação por campo (422).
API: `POST /auth/register`.

### 4. Vagas (home)
Barra de busca no topo, chips de filtro (Categoria via bottom sheet, Modalidade: Todas/Remoto/Híbrido/Presencial), lista de `VagaCard` com scroll infinito.
`VagaCard`: título, empresa, chip de categoria, modalidade, faixa de valor (`R$ 3.000 – R$ 5.000` ou `/hora`), prazo, selo "Candidatado" quando `ja_candidatou`.
Estados: loading (skeletons), vazio ("Nenhuma vaga encontrada" + limpar filtros), erro (retry), pull-to-refresh.
API: `GET /vagas`, `GET /categorias`.

### 5. Detalhe da vaga
Cabeçalho com título, empresa, chips (categoria, modalidade), bloco de valor e prazo, descrição completa, total de candidaturas. Botão fixo no rodapé: "Candidatar-se" (ou "Candidatura enviada" desabilitado se `ja_candidatou`).
Estados: loading, erro, 404 (vaga encerrada → mensagem e voltar).
API: `GET /vagas/{id}`.

### 6. Candidatar-se
Tela cheia (ou bottom sheet alto) com resumo da vaga, campo "Mensagem" (10–1000, contador), campo "Valor proposto" opcional (R$), botão "Enviar candidatura".
Estados: loading, erros por campo, sucesso → volta ao detalhe com snackbar e vai para a aba Candidaturas.
API: `POST /vagas/{id}/candidaturas`.

### 7. Candidaturas
Lista de cards: título da vaga, empresa, valor proposto, data, `StatusChip`. Toque abre detalhe resumido (bottom sheet) com mensagem enviada e, se `enviada`, botão "Retirar candidatura" com confirmação.
Estados: loading, vazio ("Você ainda não se candidatou" + botão ir para Vagas), erro, pull-to-refresh.
API: `GET /candidaturas`, `GET /candidaturas/{id}`, `DELETE /candidaturas/{id}`.

### 8. Perfil
Avatar com iniciais, nome, e-mail, bio editável (campo + salvar), botão "Sair".
API: `GET /me`, `PUT /me`, `POST /auth/logout`.

## Componentes compartilhados
`VagaCard`, `StatusChip`, `EmptyState`, `ErrorState`, `SkeletonCard`, `PrimaryButton`, `AppTextField`.
