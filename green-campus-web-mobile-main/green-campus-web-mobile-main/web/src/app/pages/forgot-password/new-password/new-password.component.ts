import { Component, inject, signal, OnInit, OnDestroy, ElementRef, ViewChildren, QueryList } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { Router, RouterLink, ActivatedRoute } from '@angular/router';
import { AuthService } from '../../../data/services/auth.service';
import { PrimaryButtonComponent } from '../../../shared/components/primary-button/primary-button.component';
import { passwordMatchValidator, passwordStrengthValidator } from '../../../core/validators/password.validator';
import { APP_CONFIG } from '../../../core/config/app-config';

@Component({
  selector: 'app-new-password',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink, PrimaryButtonComponent],
  template: `
    <div class="min-h-screen bg-accent-green-bg flex items-center justify-center p-4">
      <div class="w-full max-w-md">
        <!-- Back -->
        <a routerLink="/forgot-password" class="inline-flex items-center gap-2 text-text-secondary hover:text-accent-green mb-6 transition-colors">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
          </svg>
          <span class="text-sm font-medium">Volver</span>
        </a>

        <div class="bg-white rounded-2xl shadow-card-hover border border-border-color p-8">
          <div class="w-14 h-14 bg-accent-green-light rounded-2xl flex items-center justify-center mb-5">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-accent-green" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
            </svg>
          </div>

          <h2 class="text-xl font-semibold text-text-primary mb-1">Nueva contraseña</h2>
          <p class="text-sm text-text-secondary mb-2">
            Enviamos un código a <strong>{{ email() }}</strong>
          </p>

          @if (errorMessage()) {
            <div class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg">
              <p class="text-sm text-red-600">{{ errorMessage() }}</p>
            </div>
          }

          @if (successMessage()) {
            <div class="mb-4 p-3 bg-green-50 border border-green-200 rounded-lg">
              <p class="text-sm text-green-700">{{ successMessage() }}</p>
            </div>
          }

          <form [formGroup]="form" (ngSubmit)="onSubmit()" class="space-y-5">
            <!-- OTP -->
            <div>
              <label class="block text-sm font-medium text-text-secondary mb-3">Código de verificación (6 dígitos)</label>
              <div class="flex gap-2 justify-between" (paste)="onPaste($event)">
                @for (i of [0,1,2,3,4,5]; track i) {
                  <input
                    #otpInput
                    type="text"
                    inputmode="numeric"
                    maxlength="1"
                    class="otp-input"
                    [value]="otpDigits()[i]"
                    (input)="onOtpInput($event, i)"
                    (keydown)="onOtpKeydown($event, i)"
                    autocomplete="off"
                  />
                }
              </div>
            </div>

            <!-- New Password -->
            <div>
              <label class="block text-sm font-medium text-text-secondary mb-1.5">Nueva contraseña</label>
              <input
                formControlName="newPassword"
                type="password"
                class="input-field"
                placeholder="Mínimo 8 caracteres"
                autocomplete="new-password"
              />
              @if (form.get('newPassword')?.touched && form.get('newPassword')?.errors?.['required']) {
                <p class="text-xs text-red-500 mt-1">La contraseña es obligatoria</p>
              }
              @if (form.get('newPassword')?.touched && form.get('newPassword')?.errors?.['minLength']) {
                <p class="text-xs text-red-500 mt-1">Mínimo 8 caracteres</p>
              }
            </div>

            <!-- Confirm Password -->
            <div>
              <label class="block text-sm font-medium text-text-secondary mb-1.5">Confirmar contraseña</label>
              <input
                formControlName="confirmPassword"
                type="password"
                class="input-field"
                placeholder="Repite la contraseña"
                autocomplete="new-password"
              />
              @if (form.errors?.['passwordMismatch'] && form.get('confirmPassword')?.touched) {
                <p class="text-xs text-red-500 mt-1">Las contraseñas no coinciden</p>
              }
            </div>

            <!-- Resend timer -->
            <div class="text-center">
              @if (resendTimer() > 0) {
                <p class="text-sm text-text-muted">
                  Reenviar código en <span class="text-accent-green font-medium">{{ resendTimer() }}s</span>
                </p>
              } @else {
                <button type="button" (click)="resendCode()" class="text-sm text-accent-green hover:text-green-700 font-medium">
                  Reenviar código
                </button>
              }
            </div>

            <app-primary-button
              label="Cambiar contraseña"
              loadingText="Guardando..."
              [loading]="loading()"
            />
          </form>
        </div>
      </div>
    </div>
  `,
})
export class NewPasswordComponent implements OnInit, OnDestroy {
  @ViewChildren('otpInput') otpInputs!: QueryList<ElementRef<HTMLInputElement>>;

  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);

  loading = signal(false);
  errorMessage = signal('');
  successMessage = signal('');
  email = signal('');
  otpDigits = signal<string[]>(['', '', '', '', '', '']);
  resendTimer = signal<number>(APP_CONFIG.otpResendTimeout);

  private timerInterval?: ReturnType<typeof setInterval>;

  form = this.fb.group(
    {
      newPassword: ['', [Validators.required, passwordStrengthValidator]],
      confirmPassword: ['', [Validators.required]],
    },
    { validators: passwordMatchValidator('newPassword', 'confirmPassword') },
  );

  ngOnInit(): void {
    const email = this.route.snapshot.queryParamMap.get('email') ?? '';
    this.email.set(email);
    this.startTimer();
  }

  ngOnDestroy(): void {
    clearInterval(this.timerInterval);
  }

  private startTimer(): void {
    this.resendTimer.set(APP_CONFIG.otpResendTimeout);
    clearInterval(this.timerInterval);
    this.timerInterval = setInterval(() => {
      const current = this.resendTimer();
      if (current <= 0) {
        clearInterval(this.timerInterval);
      } else {
        this.resendTimer.set(current - 1);
      }
    }, 1000);
  }

  resendCode(): void {
    this.authService.forgotPassword({ email: this.email() }).subscribe({
      next: () => {
        this.successMessage.set('Código reenviado con éxito');
        this.startTimer();
        setTimeout(() => this.successMessage.set(''), 3000);
      },
      error: () => this.errorMessage.set('Error al reenviar el código'),
    });
  }

  onOtpInput(event: Event, index: number): void {
    const input = event.target as HTMLInputElement;
    const value = input.value.replace(/\D/g, '').slice(-1);
    const digits = [...this.otpDigits()];
    digits[index] = value;
    this.otpDigits.set(digits);
    input.value = value;

    if (value && index < 5) {
      const inputs = this.otpInputs.toArray();
      inputs[index + 1]?.nativeElement.focus();
    }
  }

  onOtpKeydown(event: KeyboardEvent, index: number): void {
    if (event.key === 'Backspace' && !this.otpDigits()[index] && index > 0) {
      const inputs = this.otpInputs.toArray();
      inputs[index - 1]?.nativeElement.focus();
    }
  }

  onPaste(event: ClipboardEvent): void {
    event.preventDefault();
    const text = event.clipboardData?.getData('text') ?? '';
    const digits = text.replace(/\D/g, '').slice(0, 6).split('');
    const padded = [...digits, ...Array(6).fill('')].slice(0, 6);
    this.otpDigits.set(padded);
    const inputs = this.otpInputs.toArray();
    inputs.forEach((inp, i) => (inp.nativeElement.value = padded[i]));
    const focusIdx = Math.min(digits.length, 5);
    inputs[focusIdx]?.nativeElement.focus();
  }

  onSubmit(): void {
    const otp = this.otpDigits().join('');
    if (otp.length < 6) {
      this.errorMessage.set('Ingresa el código completo de 6 dígitos');
      return;
    }
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.loading.set(true);
    this.errorMessage.set('');

    this.authService
      .resetPassword({
        email: this.email(),
        otp,
        newPassword: this.form.value.newPassword!,
      })
      .subscribe({
        next: () => {
          this.loading.set(false);
          this.successMessage.set('Contraseña cambiada con éxito. Redirigiendo...');
          setTimeout(() => this.router.navigate(['/login']), 1500);
        },
        error: err => {
          this.loading.set(false);
          this.errorMessage.set(err?.error?.message ?? 'Código inválido o expirado');
        },
      });
  }
}
