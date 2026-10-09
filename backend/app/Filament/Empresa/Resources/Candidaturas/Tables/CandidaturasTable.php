<?php

namespace App\Filament\Empresa\Resources\Candidaturas\Tables;

use App\Actions\Candidaturas\AtualizarStatusCandidatura;
use App\Enums\StatusCandidatura;
use App\Models\Candidatura;
use App\Models\Vaga;
use Filament\Actions\Action;
use Filament\Actions\ActionGroup;
use Filament\Actions\ViewAction;
use Filament\Notifications\Notification;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class CandidaturasTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('created_at', 'desc')
            ->columns([
                TextColumn::make('vaga.titulo')->label('Vaga')->searchable()->limit(40),
                TextColumn::make('freelancer.name')->label('Freelancer')->searchable(),
                TextColumn::make('valor_proposto')->label('Valor proposto')->money('BRL')->placeholder('—')->sortable(),
                TextColumn::make('status')->label('Status')->badge()->sortable(),
                TextColumn::make('created_at')->label('Enviada em')->dateTime('d/m/Y H:i')->sortable(),
            ])
            ->filters([
                SelectFilter::make('vaga_id')
                    ->label('Vaga')
                    ->options(fn (): array => Vaga::where('user_id', auth()->id())->orderBy('titulo')->pluck('titulo', 'id')->all()),
                SelectFilter::make('status')->label('Status')->options(StatusCandidatura::class),
            ])
            ->recordActions([
                ViewAction::make(),
                ActionGroup::make([
                    self::mudarStatus('analisar', 'Colocar em análise', StatusCandidatura::EmAnalise, 'warning'),
                    self::mudarStatus('aprovar', 'Aprovar', StatusCandidatura::Aprovada, 'success'),
                    self::mudarStatus('recusar', 'Recusar', StatusCandidatura::Recusada, 'danger'),
                ])->label('Status'),
            ]);
    }

    /** Só aparece quando a transição é permitida (R5). */
    public static function mudarStatus(string $nome, string $label, StatusCandidatura $para, string $cor): Action
    {
        return Action::make($nome)
            ->label($label)
            ->color($cor)
            ->visible(fn (Candidatura $record): bool => $record->status->podeTransicionarPara($para))
            ->authorize('update')
            ->requiresConfirmation()
            ->action(function (Candidatura $record) use ($para): void {
                app(AtualizarStatusCandidatura::class)->handle($record, $para);
                Notification::make()->title("Candidatura: {$para->getLabel()}")->success()->send();
            });
    }
}
