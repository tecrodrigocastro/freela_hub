<?php

use App\Enums\StatusCandidatura;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('candidaturas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('vaga_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->text('mensagem');
            $table->decimal('valor_proposto', 10, 2)->nullable();
            $table->string('status')->default(StatusCandidatura::Enviada->value);
            $table->timestamps();

            $table->unique(['vaga_id', 'user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('candidaturas');
    }
};
