<?php

namespace App\Enums;

use Filament\Support\Contracts\HasLabel;

enum TipoPagamento: string implements HasLabel
{
    case Fixo = 'fixo';
    case Hora = 'hora';

    public function getLabel(): string
    {
        return match ($this) {
            self::Fixo => 'Valor fixo',
            self::Hora => 'Por hora',
        };
    }
}
