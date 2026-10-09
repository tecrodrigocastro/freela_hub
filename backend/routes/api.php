<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CandidaturaController;
use App\Http\Controllers\Api\CategoriaController;
use App\Http\Controllers\Api\VagaController;
use Illuminate\Support\Facades\Route;

// Contrato: docs/API.md
Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
    Route::post('logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('me', [AuthController::class, 'me']);
    Route::put('me', [AuthController::class, 'update']);

    Route::get('categorias', [CategoriaController::class, 'index']);

    Route::get('vagas', [VagaController::class, 'index'])->name('vagas.index');
    Route::get('vagas/{vaga}', [VagaController::class, 'show'])->whereNumber('vaga')->name('vagas.show');
    Route::post('vagas/{vaga}/candidaturas', [CandidaturaController::class, 'store'])->whereNumber('vaga');

    Route::get('candidaturas', [CandidaturaController::class, 'index'])->name('candidaturas.index');
    Route::get('candidaturas/{candidatura}', [CandidaturaController::class, 'show'])->whereNumber('candidatura')->name('candidaturas.show');
    Route::delete('candidaturas/{candidatura}', [CandidaturaController::class, 'destroy'])->whereNumber('candidatura');
});
