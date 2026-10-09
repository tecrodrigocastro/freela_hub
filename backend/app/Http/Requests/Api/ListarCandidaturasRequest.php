<?php

namespace App\Http\Requests\Api;

use App\Enums\StatusCandidatura;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ListarCandidaturasRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'status' => ['nullable', Rule::enum(StatusCandidatura::class)],
            'page' => ['nullable', 'integer', 'min:1'],
        ];
    }
}
