<?php

namespace Tests\Feature\Api;

use App\Enums\StatusCandidatura;
use App\Models\Candidatura;
use App\Models\User;
use App\Models\Vaga;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class CandidaturaApiTest extends TestCase
{
    use RefreshDatabase;

    private User $freela;

    protected function setUp(): void
    {
        parent::setUp();

        $this->freela = User::factory()->freelancer()->create();
        Sanctum::actingAs($this->freela);
    }

    private function dados(array $override = []): array
    {
        return array_merge(['mensagem' => 'Tenho 3 anos de Flutter e já fiz apps de saúde.', 'valor_proposto' => 4200.0], $override);
    }

    public function test_candidatar_cria_candidatura_enviada(): void
    {
        $vaga = Vaga::factory()->create(['titulo' => 'App Flutter para clínica']);

        $this->postJson("/api/vagas/{$vaga->id}/candidaturas", $this->dados())
            ->assertCreated()
            ->assertJsonStructure(['data' => ['id', 'vaga' => ['id', 'titulo'], 'mensagem', 'valor_proposto', 'status', 'created_at']])
            ->assertJsonPath('data.vaga.titulo', 'App Flutter para clínica')
            ->assertJsonPath('data.status', 'enviada')
            ->assertJsonPath('data.valor_proposto', 4200);

        $this->assertDatabaseHas('candidaturas', ['vaga_id' => $vaga->id, 'user_id' => $this->freela->id]);
    }

    public function test_valor_proposto_e_opcional(): void
    {
        $vaga = Vaga::factory()->create();

        $this->postJson("/api/vagas/{$vaga->id}/candidaturas", ['mensagem' => 'Sem valor por enquanto.'])
            ->assertCreated()
            ->assertJsonPath('data.valor_proposto', null);
    }

    public function test_r7_valor_proposto_deve_ser_maior_que_zero(): void
    {
        $vaga = Vaga::factory()->create();

        foreach ([0, -10] as $valor) {
            $this->postJson("/api/vagas/{$vaga->id}/candidaturas", $this->dados(['valor_proposto' => $valor]))
                ->assertUnprocessable()
                ->assertJsonValidationErrors(['valor_proposto']);
        }

        $this->postJson("/api/vagas/{$vaga->id}/candidaturas", $this->dados(['valor_proposto' => 'muito']))
            ->assertJsonValidationErrors(['valor_proposto']);
    }

    public function test_mensagem_tem_de_10_a_1000_caracteres(): void
    {
        $vaga = Vaga::factory()->create();

        $this->postJson("/api/vagas/{$vaga->id}/candidaturas", $this->dados(['mensagem' => '']))->assertJsonValidationErrors(['mensagem']);
        $this->postJson("/api/vagas/{$vaga->id}/candidaturas", $this->dados(['mensagem' => 'curta']))->assertJsonValidationErrors(['mensagem']);
        $this->postJson("/api/vagas/{$vaga->id}/candidaturas", $this->dados(['mensagem' => str_repeat('a', 1001)]))->assertJsonValidationErrors(['mensagem']);
        $this->postJson("/api/vagas/{$vaga->id}/candidaturas", $this->dados(['mensagem' => str_repeat('a', 10)]))->assertCreated();
    }

    public function test_r2_candidatura_duplicada_da_422_em_vaga(): void
    {
        $vaga = Vaga::factory()->create();
        $this->postJson("/api/vagas/{$vaga->id}/candidaturas", $this->dados())->assertCreated();

        $this->postJson("/api/vagas/{$vaga->id}/candidaturas", $this->dados())
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['vaga']);

        $this->assertSame(1, Candidatura::count());
    }

    public function test_r1_vaga_encerrada_ou_inexistente_da_404(): void
    {
        $encerrada = Vaga::factory()->encerrada()->create();

        $this->postJson("/api/vagas/{$encerrada->id}/candidaturas", $this->dados())->assertNotFound();
        $this->postJson('/api/vagas/99999/candidaturas', $this->dados())->assertNotFound();
        $this->assertSame(0, Candidatura::count());
    }

    public function test_r3_empresa_nao_se_candidata(): void
    {
        Sanctum::actingAs(User::factory()->empresa()->create());
        $vaga = Vaga::factory()->create();

        $this->postJson("/api/vagas/{$vaga->id}/candidaturas", $this->dados())->assertForbidden();
        $this->postJson("/api/vagas/{$vaga->id}/candidaturas", [])->assertForbidden();
        $this->assertSame(0, Candidatura::count());
    }

    public function test_lista_so_as_minhas_mais_recentes_primeiro(): void
    {
        $antiga = Candidatura::factory()->for($this->freela, 'freelancer')->create(['created_at' => now()->subDays(2)]);
        $nova = Candidatura::factory()->for($this->freela, 'freelancer')->create(['created_at' => now()]);
        Candidatura::factory()->create();

        $this->getJson('/api/candidaturas')
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.id', $nova->id)
            ->assertJsonPath('data.1.id', $antiga->id)
            ->assertJsonStructure([
                'data' => [['id', 'vaga' => ['id', 'titulo', 'empresa'], 'valor_proposto', 'status', 'created_at']],
                'links', 'meta',
            ])
            ->assertJsonMissingPath('data.0.mensagem');
    }

    public function test_lista_filtra_por_status_e_valida_o_valor(): void
    {
        Candidatura::factory()->for($this->freela, 'freelancer')->create();
        $analise = Candidatura::factory()->for($this->freela, 'freelancer')->status(StatusCandidatura::EmAnalise)->create();

        $this->getJson('/api/candidaturas?status=em_analise')
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $analise->id);

        $this->getJson('/api/candidaturas?status=xyz')->assertUnprocessable()->assertJsonValidationErrors(['status']);
    }

    public function test_lista_pagina_de_10_em_10(): void
    {
        Candidatura::factory()->count(11)->for($this->freela, 'freelancer')->create();

        $this->getJson('/api/candidaturas')->assertJsonCount(10, 'data')->assertJsonPath('meta.total', 11);
        $this->getJson('/api/candidaturas?page=2')->assertJsonCount(1, 'data');
    }

    public function test_detalhe_traz_a_mensagem_completa(): void
    {
        $candidatura = Candidatura::factory()->for($this->freela, 'freelancer')->create(['mensagem' => 'Mensagem completa da candidatura.']);

        $this->getJson("/api/candidaturas/{$candidatura->id}")
            ->assertOk()
            ->assertJsonPath('data.mensagem', 'Mensagem completa da candidatura.')
            ->assertJsonPath('data.vaga.id', $candidatura->vaga_id);
    }

    public function test_detalhe_de_candidatura_alheia_da_403(): void
    {
        $alheia = Candidatura::factory()->create();

        $this->getJson("/api/candidaturas/{$alheia->id}")->assertForbidden();
        $this->getJson('/api/candidaturas/99999')->assertNotFound();
    }

    public function test_r6_retira_candidatura_enviada(): void
    {
        $candidatura = Candidatura::factory()->for($this->freela, 'freelancer')->create();

        $this->deleteJson("/api/candidaturas/{$candidatura->id}")->assertNoContent();

        $this->assertModelMissing($candidatura);
    }

    public function test_r6_nao_retira_candidatura_ja_em_analise(): void
    {
        $candidatura = Candidatura::factory()->for($this->freela, 'freelancer')->status(StatusCandidatura::EmAnalise)->create();

        $this->deleteJson("/api/candidaturas/{$candidatura->id}")
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['status']);

        $this->assertModelExists($candidatura);
    }

    public function test_nao_retira_candidatura_de_outro_usuario(): void
    {
        $alheia = Candidatura::factory()->create();

        $this->deleteJson("/api/candidaturas/{$alheia->id}")->assertForbidden();

        $this->assertModelExists($alheia);
    }

    public function test_r8_vaga_encerrada_continua_visivel_nas_minhas_candidaturas(): void
    {
        $candidatura = Candidatura::factory()->for($this->freela, 'freelancer')->create();
        $candidatura->vaga->update(['status' => 'encerrada']);

        $this->getJson('/api/candidaturas')->assertJsonCount(1, 'data');
        $this->getJson("/api/candidaturas/{$candidatura->id}")->assertOk();
    }

    public function test_fluxo_completo_registro_vaga_candidatura_retirada(): void
    {
        $vaga = Vaga::factory()->create();

        $token = $this->postJson('/api/auth/register', [
            'name' => 'Nova Pessoa', 'email' => 'nova@email.com',
            'password' => 'secret123', 'password_confirmation' => 'secret123',
        ])->json('token');
        $this->app['auth']->forgetGuards();

        $id = $this->withToken($token)->postJson("/api/vagas/{$vaga->id}/candidaturas", $this->dados())
            ->assertCreated()->json('data.id');
        $this->app['auth']->forgetGuards();

        $this->withToken($token)->getJson("/api/vagas/{$vaga->id}")->assertJsonPath('data.ja_candidatou', true);
        $this->app['auth']->forgetGuards();

        $this->withToken($token)->deleteJson("/api/candidaturas/{$id}")->assertNoContent();
    }
}
