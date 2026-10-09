<?php

namespace App\Models;

use App\Enums\Role;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use JeffersonGoncalves\Filament\User\Models\User as BaseUser;
use Laravel\Sanctum\HasApiTokens;

/**
 * Columns, casts, observer, Filament panel access and avatar come from
 * jeffersongoncalves/laravel-user + jeffersongoncalves/filament-user.
 * Add traits, relations or overrides here.
 *
 * @property Role $role
 * @property string|null $empresa_nome
 * @property string|null $bio
 */
class User extends BaseUser
{
    use HasApiTokens;

    protected static function newFactory(): UserFactory
    {
        return UserFactory::new();
    }

    public function getFillable(): array
    {
        return [...parent::getFillable(), 'role', 'empresa_nome', 'bio'];
    }

    protected function casts(): array
    {
        return [...parent::casts(), 'role' => Role::class];
    }

    public function isAdmin(): bool
    {
        return $this->role === Role::Admin;
    }

    public function isEmpresa(): bool
    {
        return $this->role === Role::Empresa;
    }

    public function isFreelancer(): bool
    {
        return $this->role === Role::Freelancer;
    }

    public function vagas(): HasMany
    {
        return $this->hasMany(Vaga::class);
    }

    public function candidaturas(): HasMany
    {
        return $this->hasMany(Candidatura::class);
    }
}
