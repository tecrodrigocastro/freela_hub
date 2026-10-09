<?php

namespace Database\Seeders;

use App\Models\Categoria;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class CategoriaSeeder extends Seeder
{
    public const NOMES = [
        'Desenvolvimento Web',
        'Desenvolvimento Mobile',
        'Design UI/UX',
        'Dados e IA',
        'DevOps e Cloud',
        'Marketing Digital',
        'Redação e Conteúdo',
        'QA e Suporte',
    ];

    public function run(): void
    {
        foreach (self::NOMES as $nome) {
            Categoria::updateOrCreate(['slug' => Str::slug($nome)], ['nome' => $nome]);
        }
    }
}
