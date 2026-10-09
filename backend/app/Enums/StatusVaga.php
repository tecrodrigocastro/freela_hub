<?php

namespace App\Enums;

use Filament\Support\Contracts\HasColor;
use Filament\Support\Contracts\HasLabel;

enum StatusVaga: string implements HasColor, HasLabel
{
    case Aberta = 'aberta';
    case Encerrada = 'encerrada';

    public function getLabel(): string
    {
        return match ($this) {
            self::Aberta => 'Aberta',
            self::Encerrada => 'Encerrada',
        };
    }

    public function getColor(): string
    {
        return match ($this) {
            self::Aberta => 'success',
            self::Encerrada => 'gray',
        };
    }
}
