<?php

namespace App\Actions\Candidaturas;

use App\Enums\StatusCandidatura;
use App\Enums\StatusVaga;
use App\Models\Candidatura;
use App\Models\User;
use App\Models\Vaga;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Validation\ValidationException;

class CriarCandidatura
{
    /**
     * @param  array{mensagem: string, valor_proposto?: float|int|string|null}  $dados
     *
     * @throws AuthorizationException R3: só freelancer se candidata
     * @throws ModelNotFoundException R1: só vaga aberta aceita candidatura
     * @throws ValidationException R2: uma candidatura por vaga e freelancer
     */
    public function handle(User $freelancer, Vaga $vaga, array $dados): Candidatura
    {
        if (! $freelancer->isFreelancer()) {
            throw new AuthorizationException('Somente freelancers podem se candidatar.');
        }

        if ($vaga->status !== StatusVaga::Aberta) {
            throw (new ModelNotFoundException)->setModel(Vaga::class, [$vaga->getKey()]);
        }

        if ($vaga->candidaturas()->where('user_id', $freelancer->getKey())->exists()) {
            throw ValidationException::withMessages([
                'vaga' => 'Você já se candidatou a esta vaga.',
            ]);
        }

        return $vaga->candidaturas()->create([
            'user_id' => $freelancer->getKey(),
            'mensagem' => $dados['mensagem'],
            'valor_proposto' => $dados['valor_proposto'] ?? null,
            'status' => StatusCandidatura::Enviada,
        ]);
    }
}
