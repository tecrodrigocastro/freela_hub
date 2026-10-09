<?php

namespace App\Enums;

use Filament\Support\Contracts\HasLabel;

enum Role: string implements HasLabel
{
    case Admin = 'admin';
    case Empresa = 'empresa';
    case Freelancer = 'freelancer';

    public function getLabel(): string
    {
        return match ($this) {
            self::Admin => 'Admin',
            self::Empresa => 'Empresa',
            self::Freelancer => 'Freelancer',
        };
    }
}
