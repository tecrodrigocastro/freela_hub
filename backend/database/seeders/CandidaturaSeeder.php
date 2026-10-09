<?php

namespace Database\Seeders;

use App\Enums\StatusCandidatura;
use App\Models\Candidatura;
use App\Models\User;
use App\Models\Vaga;
use Illuminate\Database\Seeder;

class CandidaturaSeeder extends Seeder
{
    public function run(): void
    {
        $freela = User::where('email', 'freela@freelahub.test')->firstOrFail();

        $candidaturas = [
            ['App Flutter para clínica', StatusCandidatura::Enviada, 'Tenho três anos de Flutter e já publiquei dois apps de saúde nas lojas. Posso começar na próxima semana.', 4200],
            ['App de fidelidade em Flutter', StatusCandidatura::EmAnalise, 'Já desenvolvi um app de fidelidade com QR Code para uma rede de cafeterias. Envio o portfólio se quiserem.', 7500],
            ['Notificações de lembrete de consulta', StatusCandidatura::Aprovada, 'Conheço bem Firebase Cloud Messaging e notificações locais. Consigo entregar em duas semanas.', null],
        ];

        foreach ($candidaturas as [$titulo, $status, $mensagem, $valor]) {
            Candidatura::updateOrCreate(
                ['vaga_id' => Vaga::where('titulo', $titulo)->firstOrFail()->id, 'user_id' => $freela->id],
                ['mensagem' => $mensagem, 'valor_proposto' => $valor, 'status' => $status],
            );
        }
    }
}
