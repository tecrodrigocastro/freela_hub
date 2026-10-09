<?php

namespace App\Providers;

use App\Models\User;
use App\Providers\Filament\AdminPanelProvider;
use App\Providers\Filament\EmpresaPanelProvider;
use App\Providers\Filament\GuestPanelProvider;
use Filament\Panel;
use Filament\Support\Colors\Color;
use Filament\Support\Facades\FilamentView;
use Filament\View\PanelsRenderHook;
use Illuminate\Contracts\View\View;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Facades\Vite;
use Illuminate\Support\ServiceProvider;
use JeffersonGoncalves\Filament\User\Facades\PanelAccess;
use STS\FilamentImpersonate\Actions\Impersonate;

use function view;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        if (config('filakit.admin_panel_enabled', false)) {
            $this->app->register(AdminPanelProvider::class);
        }
        if (config('filakit.empresa_panel_enabled', false)) {
            $this->app->register(EmpresaPanelProvider::class);
        }
        if (config('filakit.guest_panel_enabled', false)) {
            $this->app->register(GuestPanelProvider::class);
        }
        FilamentView::registerRenderHook(PanelsRenderHook::HEAD_START, fn (): View => view('components.js-md5'));
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        if (! app()->isLocal()) {
            URL::forceHttps();
            Vite::useAggressivePrefetching();
        }

        Model::automaticallyEagerLoadRelationships();

        $this->configurePanelAccess();
        $this->configureImpersonate();
    }

    /**
     * R3 / ARCHITECTURE.md: a role decide o painel. admin -> /admin, empresa -> /empresa,
     * freelancer não acessa nenhum painel (usa só a API).
     */
    private function configurePanelAccess(): void
    {
        PanelAccess::using(fn (User $user, Panel $panel): bool => $user->status && match ($panel->getId()) {
            'admin' => $user->isAdmin(),
            'empresa' => $user->isEmpresa(),
            default => false,
        });
    }

    private function configureImpersonate(): void
    {
        Impersonate::configureUsing(function (Impersonate $action) {
            return $action
                ->color(Color::Blue)
                ->hiddenLabel()
                ->button();
        });
    }
}
