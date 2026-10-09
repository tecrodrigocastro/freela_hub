<?php

namespace Database\Seeders;

use App\Enums\Role;
use App\Models\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $usuarios = [
            ['admin@freelahub.test', 'Admin FreelaHub', Role::Admin, null],
            ['empresa1@freelahub.test', 'Marina Costa', Role::Empresa, 'Clínica Vida'],
            ['empresa2@freelahub.test', 'Rafael Lima', Role::Empresa, 'Estúdio Pixel'],
            ['freela@freelahub.test', 'Ana Souza', Role::Freelancer, null],
        ];

        foreach ($usuarios as [$email, $name, $role, $empresa]) {
            User::updateOrCreate(['email' => $email], [
                'name' => $name,
                'password' => 'password',
                'role' => $role,
                'empresa_nome' => $empresa,
                'status' => true,
                'email_verified_at' => now(),
            ]);
        }
    }
}
