<?php

namespace App\Policies;

use App\Enums\StatusVaga;
use App\Models\User;
use App\Models\Vaga;

/**
 * R4: empresa só enxerga e edita as próprias vagas. Freelancer só vê vagas abertas (R1).
 */
class VagaPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isEmpresa() || $user->isFreelancer();
    }

    public function view(User $user, Vaga $vaga): bool
    {
        if ($user->isEmpresa()) {
            return $this->dono($user, $vaga);
        }

        return $user->isFreelancer() && $vaga->status === StatusVaga::Aberta;
    }

    public function create(User $user): bool
    {
        return $user->isEmpresa();
    }

    public function update(User $user, Vaga $vaga): bool
    {
        return $user->isEmpresa() && $this->dono($user, $vaga);
    }

    public function delete(User $user, Vaga $vaga): bool
    {
        return $this->update($user, $vaga);
    }

    private function dono(User $user, Vaga $vaga): bool
    {
        return $vaga->user_id === $user->getKey();
    }
}
