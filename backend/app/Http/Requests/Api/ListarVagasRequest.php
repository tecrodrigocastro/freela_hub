<?php

namespace App\Http\Requests\Api;

use App\Enums\Modalidade;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ListarVagasRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'q' => ['nullable', 'string', 'max:100'],
            'categoria_id' => ['nullable', 'integer', 'exists:categorias,id'],
            'modalidade' => ['nullable', Rule::enum(Modalidade::class)],
            'page' => ['nullable', 'integer', 'min:1'],
        ];
    }
}
