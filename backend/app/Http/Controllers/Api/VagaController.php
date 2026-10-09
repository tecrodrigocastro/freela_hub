<?php

namespace App\Http\Controllers\Api;

use App\Http\Requests\Api\ListarVagasRequest;
use App\Http\Resources\VagaResource;
use App\Models\Vaga;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class VagaController
{
    /** R1: a API só expõe vagas abertas. */
    public function index(ListarVagasRequest $request): AnonymousResourceCollection
    {
        $vagas = Vaga::query()
            ->aberta()
            ->with(['empresa', 'categoria'])
            ->withExists(['candidaturas as ja_candidatou' => fn ($q) => $q->where('user_id', $request->user()->getKey())])
            ->when($request->validated('q'), function ($query, string $q) {
                $termo = '%'.addcslashes($q, '%_\\').'%';

                $query->where(fn ($w) => $w->where('titulo', 'like', $termo)->orWhere('descricao', 'like', $termo));
            })
            ->when($request->validated('categoria_id'), fn ($query, $id) => $query->where('categoria_id', $id))
            ->when($request->validated('modalidade'), fn ($query, $m) => $query->where('modalidade', $m))
            ->latest('publicada_em')
            ->latest('id')
            ->paginate(10)
            ->withQueryString();

        return VagaResource::collection($vagas);
    }

    public function show(Request $request, int $vaga): VagaResource
    {
        $vaga = Vaga::query()
            ->aberta()
            ->with(['empresa', 'categoria'])
            ->withCount('candidaturas')
            ->withExists(['candidaturas as ja_candidatou' => fn ($q) => $q->where('user_id', $request->user()->getKey())])
            ->findOrFail($vaga);

        return VagaResource::make($vaga);
    }
}
