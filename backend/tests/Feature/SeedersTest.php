<?php

namespace Tests\Feature;

use App\Enums\Role;
use App\Enums\StatusCandidatura;
use App\Enums\StatusVaga;
use App\Models\Candidatura;
use App\Models\Categoria;
use App\Models\User;
use App\Models\Vaga;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SeedersTest extends TestCase
{
    use RefreshDatabase;

    public function test_seeders_geram_os_dados_de_demonstracao(): void
    {
        $this->seed(DatabaseSeeder::class);

        $this->assertSame(8, Categoria::count());
        $this->assertSame(1, User::where('role', Role::Admin)->count());
        $this->assertSame(2, User::where('role', Role::Empresa)->count());
        $this->assertSame(1, User::where('role', Role::Freelancer)->count());
        $this->assertSame(20, Vaga::count());
        $this->assertSame(2, Vaga::where('status', StatusVaga::Encerrada)->count());
        $this->assertTrue(Vaga::distinct()->pluck('user_id')->count() === 2);
    }

    public function test_freelancer_demo_tem_tres_candidaturas_em_status_diferentes(): void
    {
        $this->seed(DatabaseSeeder::class);

        $freela = User::where('email', 'freela@freelahub.test')->first();

        $this->assertEqualsCanonicalizing(
            [StatusCandidatura::Enviada, StatusCandidatura::EmAnalise, StatusCandidatura::Aprovada],
            Candidatura::where('user_id', $freela->id)->get()->pluck('status')->all(),
        );
    }

    public function test_credenciais_de_demonstracao_funcionam(): void
    {
        $this->seed(DatabaseSeeder::class);

        $this->assertTrue(auth()->validate(['email' => 'empresa1@freelahub.test', 'password' => 'password']));
        $this->assertTrue(auth()->validate(['email' => 'admin@freelahub.test', 'password' => 'password']));
    }

    public function test_seeders_podem_rodar_duas_vezes(): void
    {
        $this->seed(DatabaseSeeder::class);
        $this->seed(DatabaseSeeder::class);

        $this->assertSame(20, Vaga::count());
        $this->assertSame(3, Candidatura::count());
    }
}
