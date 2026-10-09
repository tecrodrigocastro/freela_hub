<?php

namespace App\Models;

use App\Enums\Modalidade;
use App\Enums\StatusVaga;
use App\Enums\TipoPagamento;
use Database\Factories\VagaFactory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Vaga extends Model
{
    /** @use HasFactory<VagaFactory> */
    use HasFactory;

    protected $fillable = [
        'user_id',
        'categoria_id',
        'titulo',
        'descricao',
        'modalidade',
        'tipo_pagamento',
        'valor_min',
        'valor_max',
        'prazo_dias',
        'status',
        'publicada_em',
    ];

    protected function casts(): array
    {
        return [
            'modalidade' => Modalidade::class,
            'tipo_pagamento' => TipoPagamento::class,
            'status' => StatusVaga::class,
            'valor_min' => 'decimal:2',
            'valor_max' => 'decimal:2',
            'prazo_dias' => 'integer',
            'publicada_em' => 'datetime',
        ];
    }

    public function empresa(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function categoria(): BelongsTo
    {
        return $this->belongsTo(Categoria::class);
    }

    public function candidaturas(): HasMany
    {
        return $this->hasMany(Candidatura::class);
    }

    public function scopeAberta(Builder $query): Builder
    {
        return $query->where('status', StatusVaga::Aberta);
    }
}
