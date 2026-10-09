<?php

namespace Database\Factories;

use App\Enums\Modalidade;
use App\Enums\StatusVaga;
use App\Enums\TipoPagamento;
use App\Models\Categoria;
use App\Models\User;
use App\Models\Vaga;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Vaga>
 */
class VagaFactory extends Factory
{
    public function definition(): array
    {
        $min = fake()->numberBetween(5, 40) * 100;

        return [
            'user_id' => User::factory()->empresa(),
            'categoria_id' => Categoria::factory(),
            'titulo' => fake()->sentence(4),
            'descricao' => fake()->paragraphs(2, true),
            'modalidade' => fake()->randomElement(Modalidade::cases()),
            'tipo_pagamento' => TipoPagamento::Fixo,
            'valor_min' => $min,
            'valor_max' => $min + fake()->numberBetween(5, 30) * 100,
            'prazo_dias' => fake()->numberBetween(7, 90),
            'status' => StatusVaga::Aberta,
            'publicada_em' => now(),
        ];
    }

    public function encerrada(): static
    {
        return $this->state(['status' => StatusVaga::Encerrada]);
    }
}
