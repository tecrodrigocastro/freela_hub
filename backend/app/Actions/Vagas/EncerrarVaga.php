<?php

namespace App\Actions\Vagas;

use App\Enums\StatusVaga;
use App\Models\Vaga;

class EncerrarVaga
{
    /**
     * R8: encerrar não apaga as candidaturas.
     */
    public function handle(Vaga $vaga): Vaga
    {
        $vaga->update(['status' => StatusVaga::Encerrada]);

        return $vaga;
    }
}
