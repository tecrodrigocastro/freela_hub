<?php

namespace App\Filament\Empresa\Resources\Vagas\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class VagaInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('titulo')->label('Título')->columnSpanFull(),
                TextEntry::make('categoria.nome')->label('Categoria'),
                TextEntry::make('status')->label('Status')->badge(),
                TextEntry::make('modalidade')->label('Modalidade')->badge(),
                TextEntry::make('tipo_pagamento')->label('Pagamento'),
                TextEntry::make('valor_min')->label('Valor mínimo')->money('BRL'),
                TextEntry::make('valor_max')->label('Valor máximo')->money('BRL'),
                TextEntry::make('prazo_dias')->label('Prazo (dias)'),
                TextEntry::make('publicada_em')->label('Publicada em')->dateTime('d/m/Y H:i'),
                TextEntry::make('descricao')->label('Descrição')->columnSpanFull(),
            ]);
    }
}
