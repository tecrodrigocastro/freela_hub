<?php

namespace App\Policies;

use App\Models\Candidatura;
use App\Models\User;

/**
 * R4: empresa só enxerga e avalia candidaturas das suas vagas.
 * Freelancer só enxerga e retira as próprias (R6 é checada na Action).
 */
class CandidaturaPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isEmpresa() || $user->isFreelancer();
    }

    public function view(User $user, Candidatura $candidatura): bool
    {
        return $this->dono($user, $candidatura) || $this->empresaDaVaga($user, $candidatura);
    }

    public function create(User $user): bool
    {
        return $user->isFreelancer();
    }

    /** Mudar o status é decisão da empresa dona da vaga. */
    public function update(User $user, Candidatura $candidatura): bool
    {
        return $this->empresaDaVaga($user, $candidatura);
    }

    /** Retirar a candidatura é ato do próprio freelancer. */
    public function delete(User $user, Candidatura $candidatura): bool
    {
        return $this->dono($user, $candidatura);
    }

    private function dono(User $user, Candidatura $candidatura): bool
    {
        return $user->isFreelancer() && $candidatura->user_id === $user->getKey();
    }

    private function empresaDaVaga(User $user, Candidatura $candidatura): bool
    {
        return $user->isEmpresa() && $candidatura->vaga->user_id === $user->getKey();
    }
}
