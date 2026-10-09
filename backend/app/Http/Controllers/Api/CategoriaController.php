<?php

namespace App\Http\Controllers\Api;

use App\Http\Resources\CategoriaResource;
use App\Models\Categoria;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class CategoriaController
{
    public function index(): AnonymousResourceCollection
    {
        return CategoriaResource::collection(Categoria::orderBy('nome')->get());
    }
}
