<?php

namespace App\Filament\Empresa\Resources\Candidaturas;

use App\Filament\Empresa\Resources\Candidaturas\Pages\ListCandidaturas;
use App\Filament\Empresa\Resources\Candidaturas\Pages\ViewCandidatura;
use App\Filament\Empresa\Resources\Candidaturas\Schemas\CandidaturaInfolist;
use App\Filament\Empresa\Resources\Candidaturas\Tables\CandidaturasTable;
use App\Models\Candidatura;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class CandidaturaResource extends Resource
{
    protected static ?string $model = Candidatura::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedUserGroup;

    protected static ?string $modelLabel = 'candidatura';

    protected static ?string $pluralModelLabel = 'candidaturas';

    /** R4: só candidaturas das vagas da empresa logada. */
    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->whereHas('vaga', fn (Builder $query) => $query->where('user_id', auth()->id()));
    }

    /** A empresa avalia candidaturas; quem cria é o freelancer, pela API. */
    public static function canCreate(): bool
    {
        return false;
    }

    public static function infolist(Schema $schema): Schema
    {
        return CandidaturaInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return CandidaturasTable::configure($table);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListCandidaturas::route('/'),
            'view' => ViewCandidatura::route('/{record}'),
        ];
    }
}
