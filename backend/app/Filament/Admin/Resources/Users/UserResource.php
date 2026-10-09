<?php

namespace App\Filament\Admin\Resources\Users;

use App\Enums\Role;
use App\Filament\Admin\Resources\Users\Pages\ManageUsers;
use App\Models\User;
use BackedEnum;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedUsers;

    protected static ?string $modelLabel = 'usuário';

    protected static ?string $pluralModelLabel = 'usuários';

    protected static ?string $recordTitleAttribute = 'name';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('name')->label('Nome')->required()->maxLength(255),
                TextInput::make('email')->label('E-mail')->email()->required()->maxLength(255)->unique(ignoreRecord: true),
                TextInput::make('password')
                    ->label('Senha')
                    ->password()
                    ->revealable()
                    ->required(fn (string $operation): bool => $operation === 'create')
                    ->dehydrated(fn (?string $state): bool => filled($state))
                    ->minLength(8),
                Select::make('role')
                    ->label('Perfil')
                    ->options(Role::class)
                    ->default(Role::Freelancer)
                    ->required()
                    ->live(),
                TextInput::make('empresa_nome')
                    ->label('Nome da empresa')
                    ->maxLength(255)
                    ->required(fn ($get): bool => self::roleIs($get, Role::Empresa))
                    ->visible(fn ($get): bool => self::roleIs($get, Role::Empresa)),
                Textarea::make('bio')
                    ->label('Bio')
                    ->visible(fn ($get): bool => self::roleIs($get, Role::Freelancer))
                    ->columnSpanFull(),
                Toggle::make('status')->label('Ativo')->default(true),
            ]);
    }

    /** O estado do Select pode vir como enum ou como string, conforme a origem. */
    private static function roleIs(callable $get, Role $role): bool
    {
        $atual = $get('role');

        return ($atual instanceof Role ? $atual : Role::tryFrom((string) $atual)) === $role;
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('name')
            ->columns([
                TextColumn::make('name')->label('Nome')->searchable()->sortable(),
                TextColumn::make('email')->label('E-mail')->searchable(),
                TextColumn::make('role')->label('Perfil')->badge()->sortable(),
                TextColumn::make('empresa_nome')->label('Empresa')->placeholder('—')->searchable(),
                IconColumn::make('status')->label('Ativo')->boolean(),
            ])
            ->filters([
                SelectFilter::make('role')->label('Perfil')->options(Role::class),
            ])
            ->recordActions([
                EditAction::make(),
                DeleteAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ManageUsers::route('/'),
        ];
    }
}
