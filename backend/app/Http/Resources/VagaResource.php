<?php

namespace App\Http\Resources;

use App\Models\Vaga;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Vaga */
class VagaResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'titulo' => $this->titulo,
            'empresa' => $this->empresa->empresa_nome ?? $this->empresa->name,
            'categoria' => ['id' => $this->categoria->id, 'nome' => $this->categoria->nome],
            'modalidade' => $this->modalidade->value,
            'tipo_pagamento' => $this->tipo_pagamento->value,
            'valor_min' => $this->valor_min === null ? null : (float) $this->valor_min,
            'valor_max' => $this->valor_max === null ? null : (float) $this->valor_max,
            'prazo_dias' => $this->prazo_dias,
            'publicada_em' => $this->publicada_em?->toIso8601ZuluString(),
            'ja_candidatou' => (bool) ($this->ja_candidatou ?? false),
            $this->mergeWhen($request->routeIs('vagas.show'), fn () => [
                'descricao' => $this->descricao,
                'total_candidaturas' => (int) $this->candidaturas_count,
            ]),
        ];
    }
}
