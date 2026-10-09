<?php

namespace App\Filament\Empresa\Resources\Vagas;

use App\Filament\Empresa\Resources\Vagas\Pages\CreateVaga;
use App\Filament\Empresa\Resources\Vagas\Pages\EditVaga;
use App\Filament\Empresa\Resources\Vagas\Pages\ListVagas;
use App\Filament\Empresa\Resources\Vagas\Pages\ViewVaga;
use App\Filament\Empresa\Resources\Vagas\Schemas\VagaForm;
use App\Filament\Empresa\Resources\Vagas\Schemas\VagaInfolist;
use App\Filament\Empresa\Resources\Vagas\Tables\VagasTable;
use App\Models\Vaga;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class VagaResource extends Resource
{
    protected static ?string $model = Vaga::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedBriefcase;

    protected static ?string $modelLabel = 'vaga';

    protected static ?string $pluralModelLabel = 'vagas';

    protected static ?string $recordTitleAttribute = 'titulo';

    /** R4: a empresa só enxerga as próprias vagas. */
    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->where('user_id', auth()->id());
    }

    public static function form(Schema $schema): Schema
    {
        return VagaForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return VagaInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return VagasTable::configure($table);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListVagas::route('/'),
            'create' => CreateVaga::route('/create'),
            'view' => ViewVaga::route('/{record}'),
            'edit' => EditVaga::route('/{record}/edit'),
        ];
    }
}
