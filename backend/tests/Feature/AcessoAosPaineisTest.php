<?php

namespace Tests\Feature;

use App\Models\User;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AcessoAosPaineisTest extends TestCase
{
    use RefreshDatabase;

    public function test_cada_role_acessa_apenas_o_seu_painel(): void
    {
        $admin = Filament::getPanel('admin');
        $empresa = Filament::getPanel('empresa');

        $this->assertTrue(User::factory()->admin()->create()->canAccessPanel($admin));
        $this->assertFalse(User::factory()->admin()->create()->canAccessPanel($empresa));

        $this->assertTrue(User::factory()->empresa()->create()->canAccessPanel($empresa));
        $this->assertFalse(User::factory()->empresa()->create()->canAccessPanel($admin));

        $freelancer = User::factory()->freelancer()->create();
        $this->assertFalse($freelancer->canAccessPanel($admin));
        $this->assertFalse($freelancer->canAccessPanel($empresa));
    }

    public function test_usuario_inativo_nao_acessa_painel(): void
    {
        $inativa = User::factory()->empresa()->inactive()->create();

        $this->assertFalse($inativa->canAccessPanel(Filament::getPanel('empresa')));
    }

    public function test_paineis_existem_nos_caminhos_esperados(): void
    {
        $this->withoutVite();

        $this->get('/admin')->assertRedirect('/admin/login');
        $this->get('/empresa')->assertRedirect('/empresa/login');
    }

    public function test_freelancer_logado_nao_entra_no_painel_da_empresa(): void
    {
        $this->withoutVite();

        $this->actingAs(User::factory()->freelancer()->create())
            ->get('/empresa')
            ->assertForbidden();
    }

    public function test_empresa_logada_entra_no_proprio_painel_e_nao_no_admin(): void
    {
        $this->withoutVite();
        $empresa = User::factory()->empresa()->create();

        $this->actingAs($empresa)->get('/empresa')->assertOk();
        $this->actingAs($empresa)->get('/admin')->assertForbidden();
    }
}
