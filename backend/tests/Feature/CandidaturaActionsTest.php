<?php

namespace Tests\Feature;

use App\Actions\Candidaturas\AtualizarStatusCandidatura;
use App\Actions\Candidaturas\CriarCandidatura;
use App\Actions\Candidaturas\RetirarCandidatura;
use App\Enums\StatusCandidatura;
use App\Models\Candidatura;
use App\Models\User;
use App\Models\Vaga;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

class CandidaturaActionsTest extends TestCase
{
    use RefreshDatabase;

    public function test_criar_candidatura_nasce_enviada(): void
    {
        $freela = User::factory()->freelancer()->create();
        $vaga = Vaga::factory()->create();

        $candidatura = (new CriarCandidatura)->handle($freela, $vaga, [
            'mensagem' => 'Tenho experiência no assunto.',
            'valor_proposto' => 1500,
        ]);

        $this->assertSame(StatusCandidatura::Enviada, $candidatura->fresh()->status);
        $this->assertSame($vaga->id, $candidatura->vaga_id);
        $this->assertSame($freela->id, $candidatura->user_id);
        $this->assertSame('1500.00', $candidatura->fresh()->valor_proposto);
    }

    public function test_valor_proposto_e_opcional(): void
    {
        $candidatura = (new CriarCandidatura)->handle(
            User::factory()->freelancer()->create(),
            Vaga::factory()->create(),
            ['mensagem' => 'Sem valor definido ainda.'],
        );

        $this->assertNull($candidatura->fresh()->valor_proposto);
    }

    public function test_r1_vaga_encerrada_nao_aceita_candidatura(): void
    {
        $this->expectException(ModelNotFoundException::class);

        (new CriarCandidatura)->handle(
            User::factory()->freelancer()->create(),
            Vaga::factory()->encerrada()->create(),
            ['mensagem' => 'Tarde demais para esta vaga.'],
        );
    }

    public function test_r2_nao_permite_candidatura_duplicada(): void
    {
        $existente = Candidatura::factory()->create();

        try {
            (new CriarCandidatura)->handle($existente->freelancer, $existente->vaga, ['mensagem' => 'Tentando de novo...']);
            $this->fail('Deveria lançar ValidationException.');
        } catch (ValidationException $e) {
            $this->assertArrayHasKey('vaga', $e->errors());
        }

        $this->assertSame(1, Candidatura::count());
    }

    #[DataProvider('rolesSemPermissao')]
    public function test_r3_so_freelancer_se_candidata(string $estado): void
    {
        $this->expectException(AuthorizationException::class);

        (new CriarCandidatura)->handle(
            User::factory()->{$estado}()->create(),
            Vaga::factory()->create(),
            ['mensagem' => 'Posso me candidatar?'],
        );
    }

    public static function rolesSemPermissao(): array
    {
        return ['empresa' => ['empresa'], 'admin' => ['admin']];
    }

    public function test_r6_retira_candidatura_enviada(): void
    {
        $candidatura = Candidatura::factory()->create();

        (new RetirarCandidatura)->handle($candidatura);

        $this->assertModelMissing($candidatura);
    }

    #[DataProvider('statusNaoRetiraveis')]
    public function test_r6_nao_retira_candidatura_ja_analisada(StatusCandidatura $status): void
    {
        $candidatura = Candidatura::factory()->status($status)->create();

        try {
            (new RetirarCandidatura)->handle($candidatura);
            $this->fail('Deveria lançar ValidationException.');
        } catch (ValidationException $e) {
            $this->assertArrayHasKey('status', $e->errors());
        }

        $this->assertModelExists($candidatura);
    }

    public static function statusNaoRetiraveis(): array
    {
        return [
            'em_analise' => [StatusCandidatura::EmAnalise],
            'aprovada' => [StatusCandidatura::Aprovada],
            'recusada' => [StatusCandidatura::Recusada],
        ];
    }

    #[DataProvider('transicoesValidas')]
    public function test_r5_transicoes_permitidas(StatusCandidatura $de, StatusCandidatura $para): void
    {
        $candidatura = Candidatura::factory()->status($de)->create();

        (new AtualizarStatusCandidatura)->handle($candidatura, $para);

        $this->assertSame($para, $candidatura->fresh()->status);
    }

    public static function transicoesValidas(): array
    {
        return [
            'enviada → em_analise' => [StatusCandidatura::Enviada, StatusCandidatura::EmAnalise],
            'em_analise → aprovada' => [StatusCandidatura::EmAnalise, StatusCandidatura::Aprovada],
            'em_analise → recusada' => [StatusCandidatura::EmAnalise, StatusCandidatura::Recusada],
        ];
    }

    #[DataProvider('transicoesInvalidas')]
    public function test_r5_transicoes_proibidas(StatusCandidatura $de, StatusCandidatura $para): void
    {
        $candidatura = Candidatura::factory()->status($de)->create();

        try {
            (new AtualizarStatusCandidatura)->handle($candidatura, $para);
            $this->fail('Deveria lançar ValidationException.');
        } catch (ValidationException $e) {
            $this->assertArrayHasKey('status', $e->errors());
        }

        $this->assertSame($de, $candidatura->fresh()->status);
    }

    public static function transicoesInvalidas(): array
    {
        return [
            'enviada → aprovada (pula análise)' => [StatusCandidatura::Enviada, StatusCandidatura::Aprovada],
            'enviada → recusada (pula análise)' => [StatusCandidatura::Enviada, StatusCandidatura::Recusada],
            'em_analise → enviada (volta)' => [StatusCandidatura::EmAnalise, StatusCandidatura::Enviada],
            'aprovada → recusada (final)' => [StatusCandidatura::Aprovada, StatusCandidatura::Recusada],
            'aprovada → em_analise (final)' => [StatusCandidatura::Aprovada, StatusCandidatura::EmAnalise],
            'recusada → aprovada (final)' => [StatusCandidatura::Recusada, StatusCandidatura::Aprovada],
            'mesmo status' => [StatusCandidatura::EmAnalise, StatusCandidatura::EmAnalise],
        ];
    }

    public function test_status_final_e_definitivo(): void
    {
        $this->assertTrue(StatusCandidatura::Aprovada->isFinal());
        $this->assertTrue(StatusCandidatura::Recusada->isFinal());
        $this->assertFalse(StatusCandidatura::Enviada->isFinal());
        $this->assertFalse(StatusCandidatura::EmAnalise->isFinal());
    }
}
