<?php

namespace App\Enums;

use Filament\Support\Contracts\HasColor;
use Filament\Support\Contracts\HasLabel;

enum StatusCandidatura: string implements HasColor, HasLabel
{
    case Enviada = 'enviada';
    case EmAnalise = 'em_analise';
    case Aprovada = 'aprovada';
    case Recusada = 'recusada';

    public function getLabel(): string
    {
        return match ($this) {
            self::Enviada => 'Enviada',
            self::EmAnalise => 'Em análise',
            self::Aprovada => 'Aprovada',
            self::Recusada => 'Recusada',
        };
    }

    public function getColor(): string
    {
        return match ($this) {
            self::Enviada => 'gray',
            self::EmAnalise => 'warning',
            self::Aprovada => 'success',
            self::Recusada => 'danger',
        };
    }

    /**
     * R5: enviada → em_analise → aprovada | recusada. Status final é definitivo.
     *
     * @return array<int, self>
     */
    public function transicoesPermitidas(): array
    {
        return match ($this) {
            self::Enviada => [self::EmAnalise],
            self::EmAnalise => [self::Aprovada, self::Recusada],
            self::Aprovada, self::Recusada => [],
        };
    }

    public function podeTransicionarPara(self $novo): bool
    {
        return in_array($novo, $this->transicoesPermitidas(), true);
    }

    public function isFinal(): bool
    {
        return $this->transicoesPermitidas() === [];
    }
}
