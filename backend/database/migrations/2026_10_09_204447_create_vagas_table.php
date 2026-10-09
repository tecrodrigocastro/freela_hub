<?php

use App\Enums\StatusVaga;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vagas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('categoria_id')->constrained();
            $table->string('titulo', 120);
            $table->text('descricao');
            $table->string('modalidade')->index();
            $table->string('tipo_pagamento');
            $table->decimal('valor_min', 10, 2)->nullable();
            $table->decimal('valor_max', 10, 2)->nullable();
            $table->unsignedSmallInteger('prazo_dias')->nullable();
            $table->string('status')->default(StatusVaga::Aberta->value)->index();
            $table->timestamp('publicada_em')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vagas');
    }
};
