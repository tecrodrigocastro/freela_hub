<?php

namespace Database\Factories;

use App\Enums\Role;
use JeffersonGoncalves\User\Database\Factories\UserFactory as BaseUserFactory;

class UserFactory extends BaseUserFactory
{
    public function definition(): array
    {
        return [...parent::definition(), 'role' => Role::Freelancer];
    }

    public function admin(): static
    {
        return $this->state(['role' => Role::Admin]);
    }

    public function empresa(): static
    {
        return $this->state(fn () => [
            'role' => Role::Empresa,
            'empresa_nome' => fake()->company(),
        ]);
    }

    public function freelancer(): static
    {
        return $this->state(['role' => Role::Freelancer]);
    }
}
