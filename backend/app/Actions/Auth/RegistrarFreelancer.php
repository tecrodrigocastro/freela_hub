<?php

namespace App\Actions\Auth;

use App\Enums\Role;
use App\Models\User;

class RegistrarFreelancer
{
    /**
     * O cadastro pela API cria sempre um freelancer. Empresas são criadas no admin/seeder.
     *
     * @param  array{name: string, email: string, password: string}  $dados
     * @return array{0: User, 1: string} usuário e token em texto puro
     */
    public function handle(array $dados): array
    {
        $user = User::create([
            'name' => $dados['name'],
            'email' => $dados['email'],
            'password' => $dados['password'],
            'role' => Role::Freelancer,
            'status' => true,
        ]);

        return [$user, $user->createToken('app')->plainTextToken];
    }
}
