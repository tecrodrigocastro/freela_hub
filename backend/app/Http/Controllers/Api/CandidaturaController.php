<?php

namespace App\Http\Controllers\Api;

use App\Actions\Candidaturas\CriarCandidatura;
use App\Actions\Candidaturas\RetirarCandidatura;
use App\Http\Requests\Api\CandidaturaRequest;
use App\Http\Requests\Api\ListarCandidaturasRequest;
use App\Http\Resources\CandidaturaResource;
use App\Models\Candidatura;
use App\Models\Vaga;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Gate;

class CandidaturaController
{
    public function index(ListarCandidaturasRequest $request): AnonymousResourceCollection
    {
        $candidaturas = $request->user()->candidaturas()
            ->with('vaga.empresa')
            ->when($request->validated('status'), fn ($query, $status) => $query->where('status', $status))
            ->latest()
            ->latest('id')
            ->paginate(10)
            ->withQueryString();

        return CandidaturaResource::collection($candidaturas);
    }

    public function show(Candidatura $candidatura): CandidaturaResource
    {
        Gate::authorize('view', $candidatura);

        return CandidaturaResource::make($candidatura->load('vaga.empresa'));
    }

    public function store(CandidaturaRequest $request, Vaga $vaga, CriarCandidatura $action): JsonResponse
    {
        $candidatura = $action->handle($request->user(), $vaga, $request->validated());

        return CandidaturaResource::make($candidatura->load('vaga.empresa'))
            ->response()
            ->setStatusCode(201);
    }

    public function destroy(Candidatura $candidatura, RetirarCandidatura $action): Response
    {
        Gate::authorize('delete', $candidatura);

        $action->handle($candidatura);

        return response()->noContent();
    }
}
