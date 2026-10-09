<?php

namespace App\Filament\Empresa\Resources\Vagas\Pages;

use App\Filament\Empresa\Resources\Vagas\VagaResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewVaga extends ViewRecord
{
    protected static string $resource = VagaResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
