<?php

namespace App\Http\Controllers\Api;

use App\Actions\Auth\AutenticarFreelancer;
use App\Actions\Auth\RegistrarFreelancer;
use App\Http\Requests\Api\LoginRequest;
use App\Http\Requests\Api\RegisterRequest;
use App\Http\Requests\Api\UpdateMeRequest;
use App\Http\Resources\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Laravel\Sanctum\PersonalAccessToken;

class AuthController
{
    public function register(RegisterRequest $request, RegistrarFreelancer $action): JsonResponse
    {
        [$user, $token] = $action->handle($request->validated());

        return response()->json([
            'token' => $token,
            'user' => UserResource::make($user)->resolve(),
        ], 201);
    }

    public function login(LoginRequest $request, AutenticarFreelancer $action): JsonResponse
    {
        [$user, $token] = $action->handle($request->validated('email'), $request->validated('password'));

        return response()->json([
            'token' => $token,
            'user' => UserResource::make($user)->resolve(),
        ]);
    }

    public function logout(Request $request): Response
    {
        $token = $request->user()->currentAccessToken();

        if ($token instanceof PersonalAccessToken) {
            $token->delete();
        }

        return response()->noContent();
    }

    public function me(Request $request): UserResource
    {
        return UserResource::make($request->user());
    }

    public function update(UpdateMeRequest $request): UserResource
    {
        $request->user()->update($request->validated());

        return UserResource::make($request->user()->fresh());
    }
}
