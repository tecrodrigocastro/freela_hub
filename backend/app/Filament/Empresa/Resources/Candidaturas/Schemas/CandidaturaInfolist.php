<?php

namespace App\Filament\Empresa\Resources\Candidaturas\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class CandidaturaInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('vaga.titulo')->label('Vaga'),
                TextEntry::make('status')->label('Status')->badge(),
                TextEntry::make('freelancer.name')->label('Freelancer'),
                TextEntry::make('freelancer.bio')->label('Bio do freelancer')->placeholder('—'),
                TextEntry::make('valor_proposto')->label('Valor proposto')->money('BRL')->placeholder('Não informado'),
                TextEntry::make('created_at')->label('Enviada em')->dateTime('d/m/Y H:i'),
                TextEntry::make('mensagem')->label('Mensagem')->columnSpanFull(),
            ]);
    }
}
