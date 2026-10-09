<?php

namespace Tests\Feature;

use App\Enums\Modalidade;
use App\Enums\Role;
use App\Enums\StatusCandidatura;
use App\Enums\StatusVaga;
use App\Models\Candidatura;
use App\Models\Categoria;
use App\Models\User;
use App\Models\Vaga;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ModeloDeDadosTest extends TestCase
{
    use RefreshDatabase;

    public function test_usuario_nasce_freelancer_por_padrao(): void
    {
        $user = User::factory()->create();

        $this->assertSame(Role::Freelancer, $user->fresh()->role);
        $this->assertTrue($user->isFreelancer());
    }

    public function test_factory_cria_usuarios_por_role(): void
    {
        $this->assertTrue(User::factory()->admin()->create()->isAdmin());

        $empresa = User::factory()->empresa()->create();
        $this->assertTrue($empresa->isEmpresa());
        $this->assertNotNull($empresa->empresa_nome);
    }

    public function test_vaga_converte_enums_e_pertence_a_empresa_e_categoria(): void
    {
        $vaga = Vaga::factory()->create(['modalidade' => 'remoto']);

        $vaga = $vaga->fresh();
        $this->assertSame(Modalidade::Remoto, $vaga->modalidade);
        $this->assertSame(StatusVaga::Aberta, $vaga->status);
        $this->assertTrue($vaga->empresa->isEmpresa());
        $this->assertInstanceOf(Categoria::class, $vaga->categoria);
    }

    public function test_scope_aberta_ignora_vagas_encerradas(): void
    {
        $aberta = Vaga::factory()->create();
        Vaga::factory()->encerrada()->create();

        $this->assertSame([$aberta->id], Vaga::aberta()->pluck('id')->all());
    }

    public function test_candidatura_nasce_enviada_e_liga_vaga_e_freelancer(): void
    {
        $candidatura = Candidatura::factory()->create()->fresh();

        $this->assertSame(StatusCandidatura::Enviada, $candidatura->status);
        $this->assertTrue($candidatura->freelancer->isFreelancer());
        $this->assertCount(1, $candidatura->vaga->candidaturas);
        $this->assertCount(1, $candidatura->freelancer->candidaturas);
    }

    public function test_freelancer_nao_pode_se_candidatar_duas_vezes_na_mesma_vaga(): void
    {
        $candidatura = Candidatura::factory()->create();

        $this->expectException(QueryException::class);

        Candidatura::factory()->create([
            'vaga_id' => $candidatura->vaga_id,
            'user_id' => $candidatura->user_id,
        ]);
    }

    public function test_apagar_empresa_apaga_vagas_e_candidaturas(): void
    {
        $candidatura = Candidatura::factory()->create();

        $candidatura->vaga->empresa->delete();

        $this->assertDatabaseCount('vagas', 0);
        $this->assertDatabaseCount('candidaturas', 0);
    }

    public function test_slug_da_categoria_e_unico(): void
    {
        Categoria::factory()->create(['slug' => 'design']);

        $this->expectException(QueryException::class);

        Categoria::factory()->create(['slug' => 'design']);
    }
}
