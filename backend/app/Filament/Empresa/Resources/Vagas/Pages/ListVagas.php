<?php

namespace App\Filament\Empresa\Resources\Vagas\Pages;

use App\Filament\Empresa\Resources\Vagas\VagaResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListVagas extends ListRecords
{
    protected static string $resource = VagaResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
