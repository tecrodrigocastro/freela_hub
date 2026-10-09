<?php

namespace Tests\Feature;

use App\Enums\Role;
use App\Filament\Admin\Resources\Categorias\Pages\ManageCategorias;
use App\Filament\Admin\Resources\Users\Pages\ManageUsers;
use App\Models\Categoria;
use App\Models\User;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class PainelAdminTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->withoutVite();
        $this->actingAs(User::factory()->admin()->create());
        Filament::setCurrentPanel('admin');
    }

    public function test_admin_cria_categoria(): void
    {
        Livewire::test(ManageCategorias::class)
            ->callAction('create', ['nome' => 'Jogos', 'slug' => 'jogos'])
            ->assertHasNoActionErrors();

        $this->assertDatabaseHas('categorias', ['nome' => 'Jogos', 'slug' => 'jogos']);
    }

    public function test_slug_da_categoria_deve_ser_unico(): void
    {
        Categoria::factory()->create(['slug' => 'jogos']);

        Livewire::test(ManageCategorias::class)
            ->callAction('create', ['nome' => 'Jogos 2', 'slug' => 'jogos'])
            ->assertHasActionErrors(['slug' => 'unique']);
    }

    public function test_admin_edita_e_remove_categoria(): void
    {
        $categoria = Categoria::factory()->create();

        Livewire::test(ManageCategorias::class)
            ->callTableAction('edit', $categoria, ['nome' => 'Renomeada', 'slug' => 'renomeada'])
            ->callTableAction('delete', $categoria);

        $this->assertModelMissing($categoria);
    }

    public function test_admin_cria_empresa_com_role_e_nome_da_empresa(): void
    {
        Livewire::test(ManageUsers::class)
            ->callAction('create', [
                'name' => 'Lia Prado',
                'email' => 'lia@loja.test',
                'password' => 'senha-segura-123',
                'role' => Role::Empresa->value,
                'empresa_nome' => 'Loja da Lia',
                'status' => true,
            ])
            ->assertHasNoActionErrors();

        $lia = User::where('email', 'lia@loja.test')->firstOrFail();
        $this->assertSame(Role::Empresa, $lia->role);
        $this->assertSame('Loja da Lia', $lia->empresa_nome);
        $this->assertTrue(auth()->validate(['email' => 'lia@loja.test', 'password' => 'senha-segura-123']));
    }

    public function test_empresa_exige_nome_da_empresa(): void
    {
        Livewire::test(ManageUsers::class)
            ->callAction('create', [
                'name' => 'Sem Empresa',
                'email' => 'sem@empresa.test',
                'password' => 'senha-segura-123',
                'role' => Role::Empresa->value,
                'status' => true,
            ])
            ->assertHasActionErrors(['empresa_nome' => 'required']);
    }

    public function test_editar_usuario_sem_senha_preserva_a_senha_atual(): void
    {
        $user = User::factory()->freelancer()->create(['password' => 'senha-antiga-123']);

        Livewire::test(ManageUsers::class)
            ->callTableAction('edit', $user, ['name' => 'Novo Nome', 'email' => $user->email, 'role' => Role::Freelancer->value]);

        $this->assertSame('Novo Nome', $user->fresh()->name);
        $this->assertTrue(auth()->validate(['email' => $user->email, 'password' => 'senha-antiga-123']));
    }
}
