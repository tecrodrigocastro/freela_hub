<?php

namespace App\Filament\Empresa\Resources\Candidaturas\Pages;

use App\Enums\StatusCandidatura;
use App\Filament\Empresa\Resources\Candidaturas\CandidaturaResource;
use App\Filament\Empresa\Resources\Candidaturas\Tables\CandidaturasTable;
use Filament\Resources\Pages\ViewRecord;

class ViewCandidatura extends ViewRecord
{
    protected static string $resource = CandidaturaResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CandidaturasTable::mudarStatus('analisar', 'Colocar em análise', StatusCandidatura::EmAnalise, 'warning'),
            CandidaturasTable::mudarStatus('aprovar', 'Aprovar', StatusCandidatura::Aprovada, 'success'),
            CandidaturasTable::mudarStatus('recusar', 'Recusar', StatusCandidatura::Recusada, 'danger'),
        ];
    }
}
