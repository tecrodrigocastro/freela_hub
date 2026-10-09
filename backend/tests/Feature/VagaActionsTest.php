<?php

namespace Tests\Feature;

use App\Actions\Vagas\EncerrarVaga;
use App\Actions\Vagas\PublicarVaga;
use App\Enums\StatusVaga;
use App\Models\Candidatura;
use App\Models\Vaga;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class VagaActionsTest extends TestCase
{
    use RefreshDatabase;

    public function test_publicar_abre_a_vaga_e_preenche_publicada_em(): void
    {
        $vaga = Vaga::factory()->create(['status' => StatusVaga::Encerrada, 'publicada_em' => null]);

        $vaga = (new PublicarVaga)->handle($vaga);

        $this->assertSame(StatusVaga::Aberta, $vaga->fresh()->status);
        $this->assertNotNull($vaga->fresh()->publicada_em);
    }

    public function test_reabrir_vaga_mantem_a_data_de_publicacao_original(): void
    {
        $original = now()->subWeek()->startOfSecond();
        $vaga = Vaga::factory()->encerrada()->create(['publicada_em' => $original]);

        (new PublicarVaga)->handle($vaga);

        $this->assertTrue($vaga->fresh()->publicada_em->equalTo($original));
    }

    public function test_encerrar_muda_o_status_e_nao_apaga_candidaturas(): void
    {
        $candidatura = Candidatura::factory()->create();

        (new EncerrarVaga)->handle($candidatura->vaga);

        $this->assertSame(StatusVaga::Encerrada, $candidatura->vaga->fresh()->status);
        $this->assertDatabaseHas('candidaturas', ['id' => $candidatura->id]);
    }
}
