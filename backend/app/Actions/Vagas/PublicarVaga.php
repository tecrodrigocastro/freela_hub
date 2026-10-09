<?php

namespace App\Actions\Vagas;

use App\Enums\StatusVaga;
use App\Models\Vaga;

class PublicarVaga
{
    /**
     * Publica (ou reabre) a vaga: status `aberta` e `publicada_em` preenchido.
     */
    public function handle(Vaga $vaga): Vaga
    {
        $vaga->update([
            'status' => StatusVaga::Aberta,
            'publicada_em' => $vaga->publicada_em ?? now(),
        ]);

        return $vaga;
    }
}
