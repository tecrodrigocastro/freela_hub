<?php

namespace App\Actions\Auth;

use App\Models\User;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AutenticarFreelancer
{
    /**
     * @return array{0: User, 1: string} usuário e token em texto puro
     *
     * @throws ValidationException credenciais inválidas (erro em `email`)
     * @throws AuthorizationException usuário que não é freelancer
     */
    public function handle(string $email, string $password): array
    {
        $user = User::where('email', $email)->first();

        if (! $user || ! $user->status || ! Hash::check($password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => 'Credenciais inválidas.',
            ]);
        }

        if (! $user->isFreelancer()) {
            throw new AuthorizationException('Este acesso é exclusivo para freelancers. Use o painel web.');
        }

        return [$user, $user->createToken('app')->plainTextToken];
    }
}
