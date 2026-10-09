<?php

namespace App\Actions\Candidaturas;

use App\Enums\StatusCandidatura;
use App\Models\Candidatura;
use Illuminate\Validation\ValidationException;

class AtualizarStatusCandidatura
{
    /**
     * R5: enviada → em_analise → aprovada | recusada. Status final é definitivo.
     *
     * @throws ValidationException
     */
    public function handle(Candidatura $candidatura, StatusCandidatura $novo): Candidatura
    {
        if (! $candidatura->status->podeTransicionarPara($novo)) {
            throw ValidationException::withMessages([
                'status' => "Transição inválida: {$candidatura->status->value} → {$novo->value}.",
            ]);
        }

        $candidatura->update(['status' => $novo]);

        return $candidatura;
    }
}
