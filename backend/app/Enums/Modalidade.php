<?php

namespace App\Enums;

use Filament\Support\Contracts\HasLabel;

enum Modalidade: string implements HasLabel
{
    case Remoto = 'remoto';
    case Hibrido = 'hibrido';
    case Presencial = 'presencial';

    public function getLabel(): string
    {
        return match ($this) {
            self::Remoto => 'Remoto',
            self::Hibrido => 'Híbrido',
            self::Presencial => 'Presencial',
        };
    }
}
