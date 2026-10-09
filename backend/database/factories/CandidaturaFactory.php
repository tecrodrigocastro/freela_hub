<?php

namespace Database\Factories;

use App\Enums\StatusCandidatura;
use App\Models\Candidatura;
use App\Models\User;
use App\Models\Vaga;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Candidatura>
 */
class CandidaturaFactory extends Factory
{
    public function definition(): array
    {
        return [
            'vaga_id' => Vaga::factory(),
            'user_id' => User::factory()->freelancer(),
            'mensagem' => fake()->paragraph(),
            'valor_proposto' => fake()->boolean() ? fake()->numberBetween(5, 50) * 100 : null,
            'status' => StatusCandidatura::Enviada,
        ];
    }

    public function status(StatusCandidatura $status): static
    {
        return $this->state(['status' => $status]);
    }
}
