<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Symfony\Component\HttpFoundation\Response;

$app = Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->web(append: [
            \App\Http\Middleware\HandleInertiaRequests::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*'),
        );

        $exceptions->respond(function (Response $response, \Throwable $exception, Request $request) {
            if (in_array($response->getStatusCode(), [404, 500, 503, 403])) {
                return Inertia::render('Error', [
                    'status' => $response->getStatusCode(),
                    'path' => $request->path(),
                ])->toResponse($request)->setStatusCode($response->getStatusCode());
            }

            return $response;
        });
    })->create();

if (isset($_ENV['APP_STORAGE_PATH']) || getenv('APP_STORAGE_PATH')) {
    $app->useStoragePath(getenv('APP_STORAGE_PATH') ?: $_ENV['APP_STORAGE_PATH']);
}

return $app;
