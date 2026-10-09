<?php

namespace Tests\Feature;

use App\Models\Candidatura;
use App\Models\User;
use App\Models\Vaga;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PoliciesTest extends TestCase
{
    use RefreshDatabase;

    public function test_empresa_ve_e_edita_apenas_as_proprias_vagas(): void
    {
        $dona = User::factory()->empresa()->create();
        $outra = User::factory()->empresa()->create();
        $vaga = Vaga::factory()->for($dona, 'empresa')->create();

        $this->assertTrue($dona->can('view', $vaga));
        $this->assertTrue($dona->can('update', $vaga));
        $this->assertTrue($dona->can('delete', $vaga));

        $this->assertFalse($outra->can('view', $vaga));
        $this->assertFalse($outra->can('update', $vaga));
        $this->assertFalse($outra->can('delete', $vaga));
    }

    public function test_apenas_empresa_cria_vagas(): void
    {
        $this->assertTrue(User::factory()->empresa()->create()->can('create', Vaga::class));
        $this->assertFalse(User::factory()->freelancer()->create()->can('create', Vaga::class));
        $this->assertFalse(User::factory()->admin()->create()->can('create', Vaga::class));
    }

    public function test_freelancer_so_ve_vaga_aberta_e_nunca_edita(): void
    {
        $freela = User::factory()->freelancer()->create();

        $this->assertTrue($freela->can('view', Vaga::factory()->create()));
        $this->assertFalse($freela->can('view', Vaga::factory()->encerrada()->create()));
        $this->assertFalse($freela->can('update', Vaga::factory()->create()));
    }

    public function test_empresa_ve_e_avalia_candidaturas_das_proprias_vagas(): void
    {
        $dona = User::factory()->empresa()->create();
        $outra = User::factory()->empresa()->create();
        $candidatura = Candidatura::factory()->for(Vaga::factory()->for($dona, 'empresa'), 'vaga')->create();

        $this->assertTrue($dona->can('view', $candidatura));
        $this->assertTrue($dona->can('update', $candidatura));

        $this->assertFalse($outra->can('view', $candidatura));
        $this->assertFalse($outra->can('update', $candidatura));
    }

    public function test_empresa_nao_cria_nem_apaga_candidaturas(): void
    {
        $dona = User::factory()->empresa()->create();
        $candidatura = Candidatura::factory()->for(Vaga::factory()->for($dona, 'empresa'), 'vaga')->create();

        $this->assertFalse($dona->can('create', Candidatura::class));
        $this->assertFalse($dona->can('delete', $candidatura));
    }

    public function test_freelancer_ve_e_retira_apenas_as_proprias_candidaturas(): void
    {
        $candidatura = Candidatura::factory()->create();
        $outro = User::factory()->freelancer()->create();

        $this->assertTrue($candidatura->freelancer->can('view', $candidatura));
        $this->assertTrue($candidatura->freelancer->can('delete', $candidatura));
        $this->assertTrue($candidatura->freelancer->can('create', Candidatura::class));

        $this->assertFalse($outro->can('view', $candidatura));
        $this->assertFalse($outro->can('delete', $candidatura));
    }

    public function test_freelancer_nao_altera_status_da_candidatura(): void
    {
        $candidatura = Candidatura::factory()->create();

        $this->assertFalse($candidatura->freelancer->can('update', $candidatura));
    }
}
