<?php

namespace App\Filament\Empresa\Resources\Vagas\Tables;

use App\Actions\Vagas\EncerrarVaga;
use App\Actions\Vagas\PublicarVaga;
use App\Enums\Modalidade;
use App\Enums\StatusVaga;
use App\Filament\Empresa\Resources\Candidaturas\CandidaturaResource;
use App\Models\Vaga;
use Filament\Actions\Action;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Notifications\Notification;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class VagasTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->modifyQueryUsing(fn ($query) => $query->withCount('candidaturas'))
            ->defaultSort('created_at', 'desc')
            ->columns([
                TextColumn::make('titulo')->label('Título')->searchable()->limit(50),
                TextColumn::make('categoria.nome')->label('Categoria')->sortable(),
                TextColumn::make('modalidade')->label('Modalidade')->badge(),
                TextColumn::make('status')->label('Status')->badge()->sortable(),
                TextColumn::make('candidaturas_count')->label('Candidaturas')->sortable(),
                TextColumn::make('publicada_em')->label('Publicada em')->dateTime('d/m/Y')->sortable(),
            ])
            ->filters([
                SelectFilter::make('status')->label('Status')->options(StatusVaga::class),
                SelectFilter::make('modalidade')->label('Modalidade')->options(Modalidade::class),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
                Action::make('candidaturas')
                    ->label('Candidaturas')
                    ->icon('heroicon-o-user-group')
                    ->url(fn (Vaga $record): string => CandidaturaResource::getUrl('index', [
                        'filters' => ['vaga_id' => ['value' => $record->id]],
                    ])),
                Action::make('publicar')
                    ->label('Reabrir')
                    ->icon('heroicon-o-arrow-path')
                    ->color('success')
                    ->visible(fn (Vaga $record): bool => $record->status === StatusVaga::Encerrada)
                    ->authorize('update')
                    ->requiresConfirmation()
                    ->action(function (Vaga $record): void {
                        app(PublicarVaga::class)->handle($record);
                        Notification::make()->title('Vaga reaberta')->success()->send();
                    }),
                Action::make('encerrar')
                    ->label('Encerrar')
                    ->icon('heroicon-o-lock-closed')
                    ->color('danger')
                    ->visible(fn (Vaga $record): bool => $record->status === StatusVaga::Aberta)
                    ->authorize('update')
                    ->requiresConfirmation()
                    ->modalDescription('As candidaturas já recebidas são mantidas.')
                    ->action(function (Vaga $record): void {
                        app(EncerrarVaga::class)->handle($record);
                        Notification::make()->title('Vaga encerrada')->success()->send();
                    }),
            ]);
    }
}
