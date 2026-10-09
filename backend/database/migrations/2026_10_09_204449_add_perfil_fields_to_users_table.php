<?php

use App\Enums\Role;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('role')->default(Role::Freelancer->value)->after('password');
            $table->string('empresa_nome')->nullable()->after('role');
            $table->text('bio')->nullable()->after('empresa_nome');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['role', 'empresa_nome', 'bio']);
        });
    }
};
