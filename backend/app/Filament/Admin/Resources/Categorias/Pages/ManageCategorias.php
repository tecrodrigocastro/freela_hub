<?php

namespace App\Filament\Admin\Resources\Categorias\Pages;

use App\Filament\Admin\Resources\Categorias\CategoriaResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ManageRecords;

class ManageCategorias extends ManageRecords
{
    protected static string $resource = CategoriaResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
