<?php

namespace Database\Seeders;

use App\Enums\Modalidade;
use App\Enums\StatusVaga;
use App\Enums\TipoPagamento;
use App\Models\Categoria;
use App\Models\User;
use App\Models\Vaga;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class VagaSeeder extends Seeder
{
    public function run(): void
    {
        $empresas = [
            1 => User::where('email', 'empresa1@freelahub.test')->firstOrFail(),
            2 => User::where('email', 'empresa2@freelahub.test')->firstOrFail(),
        ];

        foreach ($this->vagas() as $i => [$empresa, $categoria, $titulo, $descricao, $modalidade, $pagamento, $min, $max, $prazo, $status]) {
            Vaga::updateOrCreate(
                ['user_id' => $empresas[$empresa]->id, 'titulo' => $titulo],
                [
                    'categoria_id' => Categoria::where('slug', Str::slug($categoria))->firstOrFail()->id,
                    'descricao' => $descricao,
                    'modalidade' => $modalidade,
                    'tipo_pagamento' => $pagamento,
                    'valor_min' => $min,
                    'valor_max' => $max,
                    'prazo_dias' => $prazo,
                    'status' => $status,
                    'publicada_em' => now()->subDays(count($this->vagas()) - $i),
                ],
            );
        }
    }

    /**
     * @return array<int, array{int, string, string, string, Modalidade, TipoPagamento, float, float, int, StatusVaga}>
     */
    private function vagas(): array
    {
        $r = Modalidade::Remoto;
        $h = Modalidade::Hibrido;
        $p = Modalidade::Presencial;
        $fixo = TipoPagamento::Fixo;
        $hora = TipoPagamento::Hora;
        $aberta = StatusVaga::Aberta;

        return [
            [1, 'Desenvolvimento Mobile', 'App Flutter para clínica', 'Precisamos de um app para pacientes agendarem consultas e verem resultados de exames. Integração com nossa API Laravel já existente. Design pronto no Figma.', $r, $fixo, 3000, 5000, 45, $aberta],
            [1, 'Desenvolvimento Web', 'Portal de agendamento online', 'Painel web em Laravel para a recepção gerenciar a agenda dos médicos, com confirmação por e-mail e relatórios mensais.', $r, $fixo, 4000, 7000, 60, $aberta],
            [1, 'Design UI/UX', 'Redesign do app de pacientes', 'Revisão completa de fluxos e telas do app atual, com protótipo navegável e guia de componentes.', $r, $fixo, 2500, 4000, 30, $aberta],
            [1, 'Dados e IA', 'Dashboard de indicadores assistenciais', 'Construir dashboard com tempo de espera, taxa de faltas e ocupação por especialidade a partir de planilhas e do banco MySQL.', $h, $fixo, 3500, 6000, 40, $aberta],
            [1, 'Redação e Conteúdo', 'Artigos de saúde para o blog', 'Quatro artigos por mês sobre prevenção e bem-estar, revisados por nossa equipe médica. Pagamento por hora de trabalho.', $r, $hora, 60, 90, 90, $aberta],
            [1, 'QA e Suporte', 'Testes manuais do novo app', 'Executar roteiro de testes em Android e iOS e reportar bugs com evidências antes do lançamento.', $r, $hora, 45, 70, 15, $aberta],
            [1, 'DevOps e Cloud', 'Migração para AWS', 'Migrar a aplicação e o banco de um servidor único para AWS (ECS e RDS), com pipeline de deploy e backups automáticos.', $r, $fixo, 6000, 10000, 50, $aberta],
            [1, 'Marketing Digital', 'Gestão de redes sociais da clínica', 'Planejamento e publicação de conteúdo no Instagram, três posts semanais e relatório mensal de resultados.', $h, $fixo, 1800, 2800, 90, $aberta],
            [1, 'Desenvolvimento Web', 'Integração com laboratório parceiro', 'Consumir a API do laboratório para exibir resultados de exames no portal do paciente.', $r, $fixo, 2000, 3500, 20, StatusVaga::Encerrada],
            [1, 'Desenvolvimento Mobile', 'Notificações de lembrete de consulta', 'Implementar lembretes de consulta no app atual, com configuração de horário pelo paciente.', $r, $fixo, 1500, 2500, 15, $aberta],
            [2, 'Design UI/UX', 'Identidade visual para e-commerce de moda', 'Logo, paleta, tipografia e kit de redes sociais para uma loja online de moda sustentável.', $r, $fixo, 2000, 3500, 25, $aberta],
            [2, 'Desenvolvimento Web', 'Loja virtual em Laravel e Filament', 'Catálogo, carrinho e painel administrativo com controle de estoque e pedidos. Pagamento será integrado depois.', $r, $fixo, 5000, 9000, 70, $aberta],
            [2, 'Marketing Digital', 'Campanha de lançamento no Instagram e TikTok', 'Roteiros, edição de vídeos curtos e acompanhamento de métricas durante quatro semanas.', $h, $fixo, 2200, 3800, 30, $aberta],
            [2, 'Redação e Conteúdo', 'Textos para landing pages', 'Escrever cinco landing pages de serviços com foco em conversão e SEO, em português do Brasil.', $r, $fixo, 1200, 2200, 20, $aberta],
            [2, 'Dados e IA', 'Chatbot de atendimento com IA', 'Criar assistente para responder dúvidas frequentes de clientes por WhatsApp, com handoff para atendente humano.', $r, $fixo, 4500, 8000, 45, $aberta],
            [2, 'Desenvolvimento Mobile', 'App de fidelidade em Flutter', 'Aplicativo com cartão de pontos, QR Code no balcão e histórico de recompensas do cliente.', $r, $fixo, 5500, 9500, 60, $aberta],
            [2, 'QA e Suporte', 'Suporte técnico N1 para a plataforma', 'Atendimento por chat em horário comercial, registrando chamados e escalando casos para o time de desenvolvimento.', $p, $hora, 30, 45, 120, $aberta],
            [2, 'DevOps e Cloud', 'Pipeline de CI/CD com GitHub Actions', 'Configurar testes automáticos, análise estática e deploy em staging a cada pull request.', $r, $hora, 90, 140, 12, $aberta],
            [2, 'Design UI/UX', 'Pesquisa de usabilidade do checkout', 'Conduzir testes com dez usuários, analisar resultados e propor melhorias para reduzir o abandono do carrinho.', $h, $fixo, 2800, 4200, 21, $aberta],
            [2, 'Marketing Digital', 'Estratégia de e-mail marketing', 'Estruturar régua de relacionamento com carrinho abandonado, boas-vindas e pós-compra.', $r, $fixo, 1500, 2600, 14, StatusVaga::Encerrada],
        ];
    }
}
