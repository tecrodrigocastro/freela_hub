<?php

namespace App\Filament\Empresa\Resources\Vagas\Pages;

use App\Actions\Vagas\PublicarVaga;
use App\Filament\Empresa\Resources\Vagas\VagaResource;
use Filament\Resources\Pages\CreateRecord;

class CreateVaga extends CreateRecord
{
    protected static string $resource = VagaResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $data['user_id'] = auth()->id();

        return $data;
    }

    protected function afterCreate(): void
    {
        app(PublicarVaga::class)->handle($this->record);
    }
}
