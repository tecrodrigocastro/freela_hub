<?php

namespace App\Actions\Candidaturas;

use App\Enums\StatusCandidatura;
use App\Models\Candidatura;
use Illuminate\Validation\ValidationException;

class RetirarCandidatura
{
    /**
     * R6: só retira enquanto `enviada`.
     *
     * @throws ValidationException
     */
    public function handle(Candidatura $candidatura): void
    {
        if ($candidatura->status !== StatusCandidatura::Enviada) {
            throw ValidationException::withMessages([
                'status' => 'Só é possível retirar candidaturas com status enviada.',
            ]);
        }

        $candidatura->delete();
    }
}
