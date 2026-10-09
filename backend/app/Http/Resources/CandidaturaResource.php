<?php

namespace App\Http\Resources;

use App\Models\Candidatura;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Candidatura */
class CandidaturaResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'vaga' => [
                'id' => $this->vaga->id,
                'titulo' => $this->vaga->titulo,
                'empresa' => $this->vaga->empresa->empresa_nome ?? $this->vaga->empresa->name,
            ],
            // A lista não traz a mensagem; criar e detalhar sim.
            $this->mergeWhen(! $request->routeIs('candidaturas.index'), fn () => [
                'mensagem' => $this->mensagem,
            ]),
            'valor_proposto' => $this->valor_proposto === null ? null : (float) $this->valor_proposto,
            'status' => $this->status->value,
            'created_at' => $this->created_at->toIso8601ZuluString(),
        ];
    }
}
