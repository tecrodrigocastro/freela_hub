<?php

namespace Tests\Feature\Api;

use App\Models\Candidatura;
use App\Models\Categoria;
use App\Models\User;
use App\Models\Vaga;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class VagaApiTest extends TestCase
{
    use RefreshDatabase;

    private User $freela;

    protected function setUp(): void
    {
        parent::setUp();

        $this->freela = User::factory()->freelancer()->create();
        Sanctum::actingAs($this->freela);
    }

    public function test_categorias_lista_todas_ordenadas_por_nome(): void
    {
        Categoria::factory()->create(['nome' => 'Zebra', 'slug' => 'zebra']);
        Categoria::factory()->create(['nome' => 'Alfa', 'slug' => 'alfa']);

        $this->getJson('/api/categorias')
            ->assertOk()
            ->assertJsonPath('data.0', ['id' => Categoria::firstWhere('slug', 'alfa')->id, 'nome' => 'Alfa', 'slug' => 'alfa'])
            ->assertJsonPath('data.1.slug', 'zebra');
    }

    public function test_lista_tem_o_formato_do_contrato(): void
    {
        $empresa = User::factory()->empresa()->create(['empresa_nome' => 'Clínica Vida']);
        Vaga::factory()->for($empresa, 'empresa')->create([
            'valor_min' => 3000, 'valor_max' => 5000, 'prazo_dias' => 45,
            'publicada_em' => '2026-10-01 14:00:00',
        ]);

        $this->getJson('/api/vagas')
            ->assertOk()
            ->assertJsonStructure([
                'data' => [['id', 'titulo', 'empresa', 'categoria' => ['id', 'nome'], 'modalidade', 'tipo_pagamento',
                    'valor_min', 'valor_max', 'prazo_dias', 'publicada_em', 'ja_candidatou']],
                'links' => ['next', 'prev'],
                'meta' => ['current_page', 'last_page', 'total'],
            ])
            ->assertJsonPath('data.0.empresa', 'Clínica Vida')
            ->assertJsonPath('data.0.valor_min', 3000)
            ->assertJsonPath('data.0.publicada_em', '2026-10-01T14:00:00Z')
            ->assertJsonPath('data.0.ja_candidatou', false)
            ->assertJsonMissingPath('data.0.descricao');
    }

    public function test_r1_lista_so_vagas_abertas(): void
    {
        $aberta = Vaga::factory()->create();
        Vaga::factory()->encerrada()->create();

        $this->getJson('/api/vagas')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $aberta->id);
    }

    public function test_lista_pagina_de_10_em_10_mais_recentes_primeiro(): void
    {
        foreach (range(1, 12) as $i) {
            Vaga::factory()->create(['titulo' => "Vaga $i", 'publicada_em' => now()->subDays(20 - $i)]);
        }

        $this->getJson('/api/vagas')
            ->assertJsonCount(10, 'data')
            ->assertJsonPath('data.0.titulo', 'Vaga 12')
            ->assertJsonPath('meta.total', 12)
            ->assertJsonPath('meta.last_page', 2)
            ->assertJsonPath('links.prev', null)
            ->assertJsonPath('links.next', fn ($next) => str_contains($next, 'page=2'));

        $this->getJson('/api/vagas?page=2')
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.1.titulo', 'Vaga 1')
            ->assertJsonPath('links.next', null);
    }

    public function test_busca_por_texto_no_titulo_e_na_descricao(): void
    {
        $porTitulo = Vaga::factory()->create(['titulo' => 'App Flutter', 'descricao' => 'Algo']);
        $porDescricao = Vaga::factory()->create(['titulo' => 'Outra', 'descricao' => 'Precisa de Flutter']);
        Vaga::factory()->create(['titulo' => 'Laravel', 'descricao' => 'API']);

        $ids = collect($this->getJson('/api/vagas?q=flutter')->assertOk()->json('data'))->pluck('id');

        $this->assertEqualsCanonicalizing([$porTitulo->id, $porDescricao->id], $ids->all());
    }

    public function test_busca_trata_curingas_como_texto(): void
    {
        Vaga::factory()->create(['titulo' => 'Vaga comum', 'descricao' => 'texto']);

        $this->getJson('/api/vagas?q=%25')->assertOk()->assertJsonCount(0, 'data');
    }

    public function test_filtra_por_categoria_e_modalidade(): void
    {
        $categoria = Categoria::factory()->create();
        $alvo = Vaga::factory()->for($categoria)->create(['modalidade' => 'remoto']);
        Vaga::factory()->for($categoria)->create(['modalidade' => 'presencial']);
        Vaga::factory()->create(['modalidade' => 'remoto']);

        $this->getJson("/api/vagas?categoria_id={$categoria->id}&modalidade=remoto")
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $alvo->id);
    }

    public function test_filtros_invalidos_dao_422(): void
    {
        $this->getJson('/api/vagas?modalidade=lua')->assertUnprocessable()->assertJsonValidationErrors(['modalidade']);
        $this->getJson('/api/vagas?categoria_id=999')->assertUnprocessable()->assertJsonValidationErrors(['categoria_id']);
    }

    public function test_ja_candidatou_reflete_so_o_usuario_logado(): void
    {
        $minha = Vaga::factory()->create();
        $outra = Vaga::factory()->create();
        Candidatura::factory()->for($minha)->for($this->freela, 'freelancer')->create();
        Candidatura::factory()->for($outra)->create();

        $resposta = collect($this->getJson('/api/vagas')->json('data'))->keyBy('id');

        $this->assertTrue($resposta[$minha->id]['ja_candidatou']);
        $this->assertFalse($resposta[$outra->id]['ja_candidatou']);
    }

    public function test_detalhe_traz_descricao_e_total_de_candidaturas(): void
    {
        $vaga = Vaga::factory()->create(['descricao' => 'Descrição completa da vaga.']);
        Candidatura::factory()->count(3)->for($vaga)->create();

        $this->getJson("/api/vagas/{$vaga->id}")
            ->assertOk()
            ->assertJsonPath('data.id', $vaga->id)
            ->assertJsonPath('data.descricao', 'Descrição completa da vaga.')
            ->assertJsonPath('data.total_candidaturas', 3)
            ->assertJsonPath('data.ja_candidatou', false);
    }

    public function test_detalhe_de_vaga_encerrada_ou_inexistente_da_404(): void
    {
        $encerrada = Vaga::factory()->encerrada()->create();

        $this->getJson("/api/vagas/{$encerrada->id}")->assertNotFound();
        $this->getJson('/api/vagas/99999')->assertNotFound();
    }
}
