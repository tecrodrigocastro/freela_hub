<?php

namespace App\Filament\Empresa\Resources\Vagas\Schemas;

use App\Enums\Modalidade;
use App\Enums\TipoPagamento;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class VagaForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('titulo')
                    ->label('Título')
                    ->required()
                    ->maxLength(120)
                    ->columnSpanFull(),
                Select::make('categoria_id')
                    ->label('Categoria')
                    ->relationship('categoria', 'nome')
                    ->searchable()
                    ->preload()
                    ->required(),
                Textarea::make('descricao')
                    ->label('Descrição')
                    ->required()
                    ->rows(6)
                    ->columnSpanFull(),
                Select::make('modalidade')
                    ->label('Modalidade')
                    ->options(Modalidade::class)
                    ->required(),
                Select::make('tipo_pagamento')
                    ->label('Tipo de pagamento')
                    ->options(TipoPagamento::class)
                    ->required(),
                TextInput::make('valor_min')
                    ->label('Valor mínimo')
                    ->numeric()
                    ->prefix('R$')
                    ->minValue(0),
                TextInput::make('valor_max')
                    ->label('Valor máximo')
                    ->numeric()
                    ->prefix('R$')
                    ->gte('valor_min'),
                TextInput::make('prazo_dias')
                    ->label('Prazo estimado (dias)')
                    ->numeric()
                    ->integer()
                    ->minValue(1)
                    ->maxValue(65535),
            ]);
    }
}
