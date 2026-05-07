import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../data/services/auth.service';
import { TokenStorageService } from '../../data/services/token-storage.service';
import { PrimaryButtonComponent } from '../../shared/components/primary-button/primary-button.component';
import { emailValidator } from '../../core/validators/email.validator';
import { ROLE_DASHBOARD_ROUTES } from '../../core/constants/user-roles';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink, PrimaryButtonComponent],
  template: `
    <div class="min-h-screen bg-accent-green-bg flex items-center justify-center p-4">
      <div class="w-full max-w-md">
        <!-- Logo + Branding -->
        <div class="flex flex-col items-center mb-8">
          <div class="w-20 h-20 bg-accent-green rounded-2xl flex items-center justify-center shadow-lg mb-4">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 text-white" viewBox="0 0 24 24" fill="currentColor">
              <path d="M17 8C8 10 5.9 16.17 3.82 21c2.83-2.07 5.57-3.53 8.18-4.07C13.17 15.83 15.5 13 17 8z"/>
              <path d="M17 8c0 8-7 13-14 13 0-7 5-13 14-13z" opacity="0.6"/>
            </svg>
          </div>
          <h1 class="text-3xl font-bold text-text-primary">Green Campus</h1>
          <p class="text-text-secondary mt-1 text-sm">Sistema de Gestión Inteligente</p>
        </div>

        <!-- Card -->
        <div class="bg-white rounded-2xl shadow-card-hover border border-border-color p-8">
          <h2 class="text-xl font-semibold text-text-primary mb-6">Iniciar sesión</h2>

          <!-- Error message -->
          @if (errorMessage()) {
            <div class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg flex items-start gap-2">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-red-500 flex-shrink-0 mt-0.5" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
              </svg>
              <p class="text-sm text-red-600">{{ errorMessage() }}</p>
            </div>
          }

          <form [formGroup]="form" (ngSubmit)="onSubmit()" class="space-y-4">
            <!-- Email -->
            <div>
              <label class="block text-sm font-medium text-text-secondary mb-1.5">Correo electrónico</label>
              <input
                formControlName="email"
                type="email"
                class="input-field"
                placeholder="usuario@campus.edu"
                autocomplete="email"
              />
              @if (form.get('email')?.touched && form.get('email')?.errors?.['required']) {
                <p class="text-xs text-red-500 mt-1">El correo es obligatorio</p>
              }
              @if (form.get('email')?.touched && form.get('email')?.errors?.['invalidEmail']) {
                <p class="text-xs text-red-500 mt-1">Ingresa un correo válido</p>
              }
            </div>

            <!-- Password -->
            <div>
              <label class="block text-sm font-medium text-text-secondary mb-1.5">Contraseña</label>
              <div class="relative">
                <input
                  formControlName="password"
                  [type]="showPassword() ? 'text' : 'password'"
                  class="input-field pr-12"
                  placeholder="••••••••"
                  autocomplete="current-password"
                />
                <button
                  type="button"
                  (click)="showPassword.set(!showPassword())"
                  class="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted hover:text-text-secondary"
                  aria-label="Toggle password visibility"
                >
                  @if (showPassword()) {
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/>
                    </svg>
                  } @else {
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                    </svg>
                  }
                </button>
              </div>
              @if (form.get('password')?.touched && form.get('password')?.errors?.['required']) {
                <p class="text-xs text-red-500 mt-1">La contraseña es obligatoria</p>
              }
            </div>

            <!-- Forgot password link -->
            <div class="flex justify-end">
              <a routerLink="/forgot-password" class="text-sm text-accent-green hover:text-green-700 font-medium">
                ¿Olvidaste tu contraseña?
              </a>
            </div>

            <!-- Submit button -->
            <app-primary-button
              label="Iniciar sesión"
              loadingText="Iniciando sesión..."
              [loading]="loading()"
            />
          </form>
        </div>

        <p class="text-center text-xs text-text-muted mt-6">
          Green Campus © 2026 · Sistema de Gestión Ambiental
        </p>
      </div>
    </div>
  `,
})
export class LoginComponent {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private tokenStorage = inject(TokenStorageService);
  private router = inject(Router);

  loading = signal(false);
  errorMessage = signal('');
  showPassword = signal(false);

  form = this.fb.group({
    email: ['', [Validators.required, emailValidator]],
    password: ['', [Validators.required]],
  });

  constructor() {
    // Redirect if already logged in
    if (this.tokenStorage.isLoggedIn()) {
      const role = this.tokenStorage.currentUser?.role ?? '';
      const path = ROLE_DASHBOARD_ROUTES[role] ?? '/dashboard/tecnico';
      this.router.navigate([path]);
    }
  }

  onSubmit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    this.loading.set(true);
    this.errorMessage.set('');

    const { email, password } = this.form.value;
    this.authService.login({ email: email!, password: password! }).subscribe({
      next: res => {
        const path = ROLE_DASHBOARD_ROUTES[res.role] ?? '/dashboard/tecnico';
        this.router.navigate([path]);
      },
      error: err => {
        this.loading.set(false);
        const msg = err?.error?.message ?? 'Credenciales incorrectas. Intenta de nuevo.';
        this.errorMessage.set(msg);
      },
    });
  }
}
