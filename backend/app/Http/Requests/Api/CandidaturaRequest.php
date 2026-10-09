<?php

namespace App\Http\Requests\Api;

use App\Models\Candidatura;
use Illuminate\Foundation\Http\FormRequest;

class CandidaturaRequest extends FormRequest
{
    /** R3: só freelancer se candidata (403 antes da validação). */
    public function authorize(): bool
    {
        return $this->user()->can('create', Candidatura::class);
    }

    public function rules(): array
    {
        return [
            'mensagem' => ['required', 'string', 'min:10', 'max:1000'],
            'valor_proposto' => ['nullable', 'numeric', 'gt:0', 'max:99999999.99'],
        ];
    }
}
