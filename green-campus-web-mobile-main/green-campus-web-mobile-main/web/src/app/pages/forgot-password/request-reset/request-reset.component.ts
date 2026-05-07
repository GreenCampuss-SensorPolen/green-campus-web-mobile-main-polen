import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../../data/services/auth.service';
import { PrimaryButtonComponent } from '../../../shared/components/primary-button/primary-button.component';
import { emailValidator } from '../../../core/validators/email.validator';

@Component({
  selector: 'app-request-reset',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink, PrimaryButtonComponent],
  template: `
    <div class="min-h-screen bg-accent-green-bg flex items-center justify-center p-4">
      <div class="w-full max-w-md">
        <!-- Back button -->
        <a routerLink="/login" class="inline-flex items-center gap-2 text-text-secondary hover:text-accent-green mb-6 transition-colors">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
          </svg>
          <span class="text-sm font-medium">Volver al login</span>
        </a>

        <div class="bg-white rounded-2xl shadow-card-hover border border-border-color p-8">
          <!-- Icon -->
          <div class="w-14 h-14 bg-accent-green-light rounded-2xl flex items-center justify-center mb-5">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-accent-green" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
            </svg>
          </div>

          <h2 class="text-xl font-semibold text-text-primary mb-2">Recuperar contraseña</h2>
          <p class="text-sm text-text-secondary mb-6">
            Ingresa tu correo electrónico y te enviaremos un código de verificación.
          </p>

          @if (successMessage()) {
            <div class="mb-4 p-3 bg-green-50 border border-green-200 rounded-lg flex items-start gap-2">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-accent-green flex-shrink-0 mt-0.5" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
              </svg>
              <p class="text-sm text-green-700">{{ successMessage() }}</p>
            </div>
          }

          @if (errorMessage()) {
            <div class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg">
              <p class="text-sm text-red-600">{{ errorMessage() }}</p>
            </div>
          }

          <form [formGroup]="form" (ngSubmit)="onSubmit()" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-text-secondary mb-1.5">Correo electrónico</label>
              <input
                formControlName="email"
                type="email"
                class="input-field"
                placeholder="usuario@campus.edu"
              />
              @if (form.get('email')?.touched && form.get('email')?.errors?.['required']) {
                <p class="text-xs text-red-500 mt-1">El correo es obligatorio</p>
              }
              @if (form.get('email')?.touched && form.get('email')?.errors?.['invalidEmail']) {
                <p class="text-xs text-red-500 mt-1">Ingresa un correo válido</p>
              }
            </div>

            <app-primary-button
              label="Enviar código"
              loadingText="Enviando..."
              [loading]="loading()"
            />
          </form>
        </div>
      </div>
    </div>
  `,
})
export class RequestResetComponent {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private router = inject(Router);

  loading = signal(false);
  errorMessage = signal('');
  successMessage = signal('');

  form = this.fb.group({
    email: ['', [Validators.required, emailValidator]],
  });

  onSubmit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    this.loading.set(true);
    this.errorMessage.set('');
    this.successMessage.set('');

    const email = this.form.value.email!;
    this.authService.forgotPassword({ email }).subscribe({
      next: () => {
        this.loading.set(false);
        this.successMessage.set('Código enviado. Redirigiendo...');
        setTimeout(() => {
          this.router.navigate(['/new-password'], { queryParams: { email } });
        }, 1500);
      },
      error: err => {
        this.loading.set(false);
        this.errorMessage.set(err?.error?.message ?? 'Error al enviar el código. Intenta de nuevo.');
      },
    });
  }
}
