<?php

namespace App\Filament\Empresa\Resources\Vagas\Pages;

use App\Filament\Empresa\Resources\Vagas\VagaResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditVaga extends EditRecord
{
    protected static string $resource = VagaResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }
}
