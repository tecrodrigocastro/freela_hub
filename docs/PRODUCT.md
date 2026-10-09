# PRODUCT — FreelaHub

## Visão
Um quadro de vagas freelance simples: a empresa publica um trabalho pontual, o freelancer encontra, se candidata com uma proposta e acompanha a resposta.

## Personas
- **Empresa** — usa o painel web (Filament). Publica vagas, vê candidatos e muda o status de cada candidatura.
- **Freelancer** — usa o app Flutter. Cria conta, busca vagas, se candidata e acompanha o status.
- **Admin** — usa o painel web. Gerencia categorias e usuários.

## Fluxos principais
1. **Empresa publica vaga**: login no painel → Vagas → Nova → preenche → publica (status `aberta`).
2. **Freelancer se candidata**: abre o app → lista de vagas (busca/filtros) → detalhe → "Candidatar-se" → mensagem + valor proposto → envia.
3. **Empresa avalia**: painel → Candidaturas da vaga → altera status (`em_analise`, `aprovada`, `recusada`).
4. **Freelancer acompanha**: aba "Candidaturas" no app mostra o status atualizado (puxar para atualizar).

## Dentro do escopo
- Cadastro e login do freelancer (app) e da empresa (painel, criada por seeder/admin).
- CRUD de vagas pelo painel da empresa.
- Listagem paginada, busca por texto e filtros (categoria, modalidade) no app.
- Candidatura única por vaga e por freelancer; retirar candidatura enquanto `enviada`.
- Gestão de status de candidaturas no painel.
- Perfil simples do freelancer (nome, bio) e logout.

## Fora do escopo
Upload de arquivos/currículo, pagamentos, chat, push, cadastro de empresa pela API, login social, avaliação de freelancers, i18n.

## Categorias iniciais
Desenvolvimento Web · Desenvolvimento Mobile · Design UI/UX · Dados e IA · DevOps e Cloud · Marketing Digital · Redação e Conteúdo · QA e Suporte

## Regras de negócio
- R1. Só vagas `aberta` aparecem na API e aceitam candidatura.
- R2. Um freelancer só pode se candidatar uma vez por vaga (unique no banco + validação).
- R3. Somente `role = freelancer` pode se candidatar via API; `empresa` acessa só o painel.
- R4. Empresa só enxerga e edita suas próprias vagas e as candidaturas delas (Policy).
- R5. Candidatura nasce `enviada`; transições permitidas: `enviada → em_analise → aprovada | recusada`. Qualquer status final é definitivo.
- R6. Freelancer só retira (DELETE) candidatura com status `enviada`.
- R7. `valor_proposto` é opcional; se informado, > 0.
- R8. Encerrar uma vaga (`encerrada`) não apaga candidaturas.

## Dados de demonstração (seeder)
- 1 admin: `admin@freelahub.test` / `password`
- 2 empresas: `empresa1@freelahub.test`, `empresa2@freelahub.test` / `password`
- 1 freelancer: `freela@freelahub.test` / `password`
- 8 categorias e ~20 vagas distribuídas entre as empresas
