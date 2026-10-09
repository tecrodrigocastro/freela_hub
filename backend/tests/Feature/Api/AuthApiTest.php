<?php

namespace Tests\Feature\Api;

use App\Enums\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    use RefreshDatabase;

    private function dadosDeCadastro(array $override = []): array
    {
        return array_merge([
            'name' => 'Ana Souza',
            'email' => 'ana@email.com',
            'password' => 'secret123',
            'password_confirmation' => 'secret123',
        ], $override);
    }

    public function test_register_cria_freelancer_e_devolve_token(): void
    {
        $this->postJson('/api/auth/register', $this->dadosDeCadastro())
            ->assertCreated()
            ->assertJsonStructure(['token', 'user' => ['id', 'name', 'email', 'role', 'bio']])
            ->assertJsonPath('user.email', 'ana@email.com')
            ->assertJsonPath('user.role', 'freelancer')
            ->assertJsonPath('user.bio', null);

        $this->assertDatabaseHas('users', ['email' => 'ana@email.com', 'role' => 'freelancer']);
    }

    public function test_register_ignora_tentativa_de_escolher_role(): void
    {
        $this->postJson('/api/auth/register', $this->dadosDeCadastro(['role' => 'admin']))
            ->assertCreated()
            ->assertJsonPath('user.role', 'freelancer');

        $this->assertSame(Role::Freelancer, User::firstWhere('email', 'ana@email.com')->role);
    }

    public function test_token_do_register_autentica_requisicoes(): void
    {
        $token = $this->postJson('/api/auth/register', $this->dadosDeCadastro())->json('token');

        $this->withToken($token)->getJson('/api/me')
            ->assertOk()
            ->assertJsonPath('data.email', 'ana@email.com');
    }

    public function test_register_valida_os_campos(): void
    {
        $this->postJson('/api/auth/register', [])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['name', 'email', 'password']);

        $this->postJson('/api/auth/register', $this->dadosDeCadastro(['password_confirmation' => 'outra']))
            ->assertJsonValidationErrors(['password']);

        $this->postJson('/api/auth/register', $this->dadosDeCadastro(['password' => 'curta', 'password_confirmation' => 'curta']))
            ->assertJsonValidationErrors(['password']);

        $this->postJson('/api/auth/register', $this->dadosDeCadastro(['email' => 'nao-e-email']))
            ->assertJsonValidationErrors(['email']);
    }

    public function test_register_rejeita_email_ja_cadastrado(): void
    {
        User::factory()->create(['email' => 'ana@email.com']);

        $this->postJson('/api/auth/register', $this->dadosDeCadastro())
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['email']);
    }

    public function test_login_devolve_token_e_usuario(): void
    {
        User::factory()->freelancer()->create(['email' => 'freela@freelahub.test', 'password' => 'password']);

        $this->postJson('/api/auth/login', ['email' => 'freela@freelahub.test', 'password' => 'password'])
            ->assertOk()
            ->assertJsonStructure(['token', 'user' => ['id', 'name', 'email', 'role', 'bio']])
            ->assertJsonPath('user.role', 'freelancer');
    }

    public function test_login_com_credenciais_invalidas_da_422_em_email(): void
    {
        User::factory()->freelancer()->create(['email' => 'freela@freelahub.test', 'password' => 'password']);

        $this->postJson('/api/auth/login', ['email' => 'freela@freelahub.test', 'password' => 'errada'])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['email']);

        $this->postJson('/api/auth/login', ['email' => 'ninguem@freelahub.test', 'password' => 'password'])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['email']);
    }

    public function test_login_de_quem_nao_e_freelancer_da_403(): void
    {
        User::factory()->empresa()->create(['email' => 'empresa@freelahub.test', 'password' => 'password']);
        User::factory()->admin()->create(['email' => 'admin@freelahub.test', 'password' => 'password']);

        $this->postJson('/api/auth/login', ['email' => 'empresa@freelahub.test', 'password' => 'password'])->assertForbidden();
        $this->postJson('/api/auth/login', ['email' => 'admin@freelahub.test', 'password' => 'password'])->assertForbidden();
    }

    public function test_login_de_freelancer_inativo_e_recusado(): void
    {
        User::factory()->freelancer()->inactive()->create(['email' => 'off@freelahub.test', 'password' => 'password']);

        $this->postJson('/api/auth/login', ['email' => 'off@freelahub.test', 'password' => 'password'])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['email']);
    }

    public function test_senha_errada_de_empresa_nao_revela_o_role(): void
    {
        User::factory()->empresa()->create(['email' => 'empresa@freelahub.test', 'password' => 'password']);

        $this->postJson('/api/auth/login', ['email' => 'empresa@freelahub.test', 'password' => 'errada'])
            ->assertUnprocessable();
    }

    public function test_logout_revoga_o_token(): void
    {
        User::factory()->freelancer()->create(['email' => 'freela@freelahub.test', 'password' => 'password']);
        $token = $this->postJson('/api/auth/login', ['email' => 'freela@freelahub.test', 'password' => 'password'])->json('token');

        $this->withToken($token)->postJson('/api/auth/logout')->assertNoContent();
        $this->assertDatabaseCount('personal_access_tokens', 0);

        $this->app['auth']->forgetGuards();
        $this->withToken($token)->getJson('/api/me')->assertUnauthorized();
    }

    public function test_rotas_protegidas_exigem_token(): void
    {
        $this->getJson('/api/me')->assertUnauthorized();
        $this->postJson('/api/auth/logout')->assertUnauthorized();
        $this->getJson('/api/vagas')->assertUnauthorized();
    }

    public function test_api_responde_json_mesmo_sem_accept(): void
    {
        $this->get('/api/me')->assertUnauthorized()->assertJsonPath('message', 'Unauthenticated.');
    }

    public function test_me_devolve_o_usuario_logado(): void
    {
        $user = User::factory()->freelancer()->create(['bio' => 'Dev Flutter']);
        Sanctum::actingAs($user);

        $this->getJson('/api/me')
            ->assertOk()
            ->assertExactJson(['data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => 'freelancer',
                'bio' => 'Dev Flutter',
            ]]);
    }

    public function test_put_me_atualiza_nome_e_bio(): void
    {
        $user = User::factory()->freelancer()->create();
        Sanctum::actingAs($user);

        $this->putJson('/api/me', ['name' => 'Ana S.', 'bio' => 'Dev Flutter, 3 anos'])
            ->assertOk()
            ->assertJsonPath('data.name', 'Ana S.')
            ->assertJsonPath('data.bio', 'Dev Flutter, 3 anos');

        $this->assertSame('Ana S.', $user->fresh()->name);
    }

    public function test_put_me_nao_altera_role_nem_email(): void
    {
        $user = User::factory()->freelancer()->create(['email' => 'ana@email.com']);
        Sanctum::actingAs($user);

        $this->putJson('/api/me', ['name' => 'Ana', 'role' => 'admin', 'email' => 'outro@email.com'])->assertOk();

        $this->assertSame(Role::Freelancer, $user->fresh()->role);
        $this->assertSame('ana@email.com', $user->fresh()->email);
    }

    public function test_put_me_valida_nome(): void
    {
        Sanctum::actingAs(User::factory()->freelancer()->create());

        $this->putJson('/api/me', ['name' => ''])->assertUnprocessable()->assertJsonValidationErrors(['name']);
    }

    public function test_put_me_permite_limpar_a_bio(): void
    {
        $user = User::factory()->freelancer()->create(['bio' => 'algo']);
        Sanctum::actingAs($user);

        $this->putJson('/api/me', ['bio' => null])->assertOk()->assertJsonPath('data.bio', null);
    }
}
