<?php

namespace Tests\Feature;

use App\Enums\StatusCandidatura;
use App\Enums\StatusVaga;
use App\Filament\Empresa\Resources\Candidaturas\Pages\ListCandidaturas;
use App\Filament\Empresa\Resources\Candidaturas\Pages\ViewCandidatura;
use App\Filament\Empresa\Resources\Vagas\Pages\CreateVaga;
use App\Filament\Empresa\Resources\Vagas\Pages\EditVaga;
use App\Filament\Empresa\Resources\Vagas\Pages\ListVagas;
use App\Models\Candidatura;
use App\Models\Categoria;
use App\Models\User;
use App\Models\Vaga;
use Filament\Actions\Testing\TestAction;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class PainelEmpresaTest extends TestCase
{
    use RefreshDatabase;

    private User $empresa;

    protected function setUp(): void
    {
        parent::setUp();

        $this->withoutVite();
        $this->empresa = User::factory()->empresa()->create();
        $this->actingAs($this->empresa);
        Filament::setCurrentPanel('empresa');
    }

    public function test_lista_mostra_apenas_as_vagas_da_empresa_logada(): void
    {
        $minhas = Vaga::factory()->count(2)->for($this->empresa, 'empresa')->create();
        $deOutra = Vaga::factory()->create();

        Livewire::test(ListVagas::class)
            ->assertCanSeeTableRecords($minhas)
            ->assertCanNotSeeTableRecords([$deOutra]);
    }

    public function test_empresa_cria_vaga_que_ja_nasce_publicada_e_dela(): void
    {
        $categoria = Categoria::factory()->create();

        Livewire::test(CreateVaga::class)
            ->fillForm([
                'titulo' => 'Landing page para campanha',
                'categoria_id' => $categoria->id,
                'descricao' => 'Precisamos de uma landing page responsiva.',
                'modalidade' => 'remoto',
                'tipo_pagamento' => 'fixo',
                'valor_min' => 1000,
                'valor_max' => 2000,
                'prazo_dias' => 15,
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $vaga = Vaga::where('titulo', 'Landing page para campanha')->firstOrFail();
        $this->assertSame($this->empresa->id, $vaga->user_id);
        $this->assertSame(StatusVaga::Aberta, $vaga->status);
        $this->assertNotNull($vaga->publicada_em);
    }

    public function test_valor_maximo_nao_pode_ser_menor_que_o_minimo(): void
    {
        Livewire::test(CreateVaga::class)
            ->fillForm([
                'titulo' => 'x',
                'categoria_id' => Categoria::factory()->create()->id,
                'descricao' => 'y',
                'modalidade' => 'remoto',
                'tipo_pagamento' => 'fixo',
                'valor_min' => 2000,
                'valor_max' => 1000,
            ])
            ->call('create')
            ->assertHasFormErrors(['valor_max']);
    }

    public function test_titulo_tem_no_maximo_120_caracteres(): void
    {
        Livewire::test(CreateVaga::class)
            ->fillForm(['titulo' => str_repeat('a', 121)])
            ->call('create')
            ->assertHasFormErrors(['titulo' => 'max']);
    }

    public function test_empresa_encerra_vaga_sem_apagar_candidaturas(): void
    {
        $vaga = Vaga::factory()->for($this->empresa, 'empresa')->create();
        Candidatura::factory()->for($vaga)->create();

        Livewire::test(ListVagas::class)
            ->callAction(TestAction::make('encerrar')->table($vaga))
            ->assertNotified();

        $this->assertSame(StatusVaga::Encerrada, $vaga->fresh()->status);
        $this->assertSame(1, $vaga->candidaturas()->count());
    }

    public function test_empresa_reabre_vaga_encerrada(): void
    {
        $vaga = Vaga::factory()->for($this->empresa, 'empresa')->encerrada()->create();

        Livewire::test(ListVagas::class)
            ->assertActionHidden(TestAction::make('encerrar')->table($vaga))
            ->callAction(TestAction::make('publicar')->table($vaga));

        $this->assertSame(StatusVaga::Aberta, $vaga->fresh()->status);
    }

    public function test_empresa_nao_edita_vaga_de_outra(): void
    {
        $deOutra = Vaga::factory()->create();

        Livewire::test(EditVaga::class, ['record' => $deOutra->getKey()])->assertNotFound();
    }

    public function test_lista_de_candidaturas_mostra_apenas_as_das_vagas_da_empresa(): void
    {
        $minha = Candidatura::factory()->for(Vaga::factory()->for($this->empresa, 'empresa'), 'vaga')->create();
        $alheia = Candidatura::factory()->create();

        Livewire::test(ListCandidaturas::class)
            ->assertCanSeeTableRecords([$minha])
            ->assertCanNotSeeTableRecords([$alheia]);
    }

    public function test_lista_de_candidaturas_filtra_por_vaga(): void
    {
        $vagaA = Vaga::factory()->for($this->empresa, 'empresa')->create();
        $vagaB = Vaga::factory()->for($this->empresa, 'empresa')->create();
        $daA = Candidatura::factory()->for($vagaA)->create();
        $daB = Candidatura::factory()->for($vagaB)->create();

        Livewire::test(ListCandidaturas::class)
            ->filterTable('vaga_id', $vagaA->id)
            ->assertCanSeeTableRecords([$daA])
            ->assertCanNotSeeTableRecords([$daB]);
    }

    public function test_empresa_muda_status_seguindo_as_transicoes(): void
    {
        $candidatura = Candidatura::factory()->for(Vaga::factory()->for($this->empresa, 'empresa'), 'vaga')->create();

        Livewire::test(ListCandidaturas::class)
            ->assertActionHidden(TestAction::make('aprovar')->table($candidatura))
            ->callAction(TestAction::make('analisar')->table($candidatura));
        $this->assertSame(StatusCandidatura::EmAnalise, $candidatura->fresh()->status);

        Livewire::test(ListCandidaturas::class)
            ->assertActionHidden(TestAction::make('analisar')->table($candidatura))
            ->callAction(TestAction::make('aprovar')->table($candidatura));
        $this->assertSame(StatusCandidatura::Aprovada, $candidatura->fresh()->status);
    }

    public function test_status_final_nao_oferece_nenhuma_acao(): void
    {
        $candidatura = Candidatura::factory()->status(StatusCandidatura::Recusada)
            ->for(Vaga::factory()->for($this->empresa, 'empresa'), 'vaga')->create();

        Livewire::test(ViewCandidatura::class, ['record' => $candidatura->getKey()])
            ->assertActionHidden('analisar')
            ->assertActionHidden('aprovar')
            ->assertActionHidden('recusar');
    }

    public function test_empresa_nao_ve_candidatura_de_vaga_alheia(): void
    {
        $alheia = Candidatura::factory()->create();

        Livewire::test(ViewCandidatura::class, ['record' => $alheia->getKey()])->assertNotFound();
    }
}
