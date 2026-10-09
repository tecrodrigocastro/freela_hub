<?php

namespace App\Models;

use App\Enums\StatusCandidatura;
use Database\Factories\CandidaturaFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Candidatura extends Model
{
    /** @use HasFactory<CandidaturaFactory> */
    use HasFactory;

    protected $fillable = ['vaga_id', 'user_id', 'mensagem', 'valor_proposto', 'status'];

    protected function casts(): array
    {
        return [
            'valor_proposto' => 'decimal:2',
            'status' => StatusCandidatura::class,
        ];
    }

    public function vaga(): BelongsTo
    {
        return $this->belongsTo(Vaga::class);
    }

    public function freelancer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
