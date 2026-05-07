import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { ProfileService } from '../../../data/services/profile.service';
import { TokenStorageService } from '../../../data/services/token-storage.service';
import { AppHeaderComponent } from '../../../shared/components/app-header/app-header.component';
import { AppSidebarComponent } from '../../../shared/components/app-sidebar/app-sidebar.component';
import { PrimaryButtonComponent } from '../../../shared/components/primary-button/primary-button.component';
import { passwordMatchValidator } from '../../../core/validators/password.validator';

@Component({
  selector: 'app-edit-profile',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink, AppHeaderComponent, AppSidebarComponent, PrimaryButtonComponent],
  template: `
    <div class="flex h-screen bg-surface overflow-hidden">
      <app-sidebar [isOpen]="sidebarOpen()" (close)="sidebarOpen.set(false)" class="hidden lg:flex"/>
      <app-sidebar [isOpen]="sidebarOpen()" (close)="sidebarOpen.set(false)" class="flex lg:hidden"/>

      <div class="flex-1 flex flex-col overflow-hidden">
        <app-header (menuToggle)="sidebarOpen.set(!sidebarOpen())" />

        <main class="flex-1 overflow-y-auto p-4 lg:p-8">
          <div class="max-w-2xl mx-auto">
            <!-- Back button -->
            <a routerLink="/profile" class="inline-flex items-center gap-2 text-text-secondary hover:text-accent-green mb-6 transition-colors">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
              </svg>
              <span class="text-sm font-medium">Volver al perfil</span>
            </a>

            <h1 class="text-2xl font-bold text-text-primary mb-6">Editar Perfil</h1>

            <div class="card p-6 lg:p-8">
              @if (successMessage()) {
                <div class="mb-5 p-3 bg-green-50 border border-green-200 rounded-lg flex items-center gap-2">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-accent-green" viewBox="0 0 20 20" fill="currentColor">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                  </svg>
                  <p class="text-sm text-green-700">{{ successMessage() }}</p>
                </div>
              }

              @if (errorMessage()) {
                <div class="mb-5 p-3 bg-red-50 border border-red-200 rounded-lg">
                  <p class="text-sm text-red-600">{{ errorMessage() }}</p>
                </div>
              }

              <form [formGroup]="form" (ngSubmit)="onSubmit()" class="space-y-5">
                <!-- Personal info section -->
                <div>
                  <h3 class="text-sm font-semibold text-text-primary uppercase tracking-wide mb-4">
                    Información personal
                  </h3>
                  <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label class="block text-sm font-medium text-text-secondary mb-1.5">Nombre</label>
                      <input formControlName="firstName" type="text" class="input-field" placeholder="Tu nombre"/>
                      @if (form.get('firstName')?.touched && form.get('firstName')?.errors?.['required']) {
                        <p class="text-xs text-red-500 mt-1">El nombre es obligatorio</p>
                      }
                    </div>
                    <div>
                      <label class="block text-sm font-medium text-text-secondary mb-1.5">Apellido</label>
                      <input formControlName="lastName" type="text" class="input-field" placeholder="Tu apellido"/>
                      @if (form.get('lastName')?.touched && form.get('lastName')?.errors?.['required']) {
                        <p class="text-xs text-red-500 mt-1">El apellido es obligatorio</p>
                      }
                    </div>
                  </div>
                </div>

                <div class="border-t border-border-color pt-5">
                  <h3 class="text-sm font-semibold text-text-primary uppercase tracking-wide mb-1">
                    Cambiar contraseña <span class="text-text-muted font-normal normal-case">(opcional)</span>
                  </h3>
                  <p class="text-xs text-text-muted mb-4">Deja en blanco si no quieres cambiar tu contraseña</p>

                  <div class="space-y-4">
                    <div>
                      <label class="block text-sm font-medium text-text-secondary mb-1.5">Nueva contraseña</label>
                      <input
                        formControlName="newPassword"
                        type="password"
                        class="input-field"
                        placeholder="Mínimo 8 caracteres"
                        autocomplete="new-password"
                      />
                    </div>
                    <div>
                      <label class="block text-sm font-medium text-text-secondary mb-1.5">Confirmar contraseña</label>
                      <input
                        formControlName="confirmPassword"
                        type="password"
                        class="input-field"
                        placeholder="Repite la nueva contraseña"
                        autocomplete="new-password"
                      />
                      @if (form.errors?.['passwordMismatch'] && form.get('confirmPassword')?.touched) {
                        <p class="text-xs text-red-500 mt-1">Las contraseñas no coinciden</p>
                      }
                    </div>
                  </div>
                </div>

                <div class="pt-2 flex gap-3">
                  <a
                    routerLink="/profile"
                    class="flex-1 text-center py-3 px-4 rounded-lg border-2 border-border-color text-text-secondary hover:bg-surface transition-colors text-sm font-medium"
                  >
                    Cancelar
                  </a>
                  <div class="flex-1">
                    <app-primary-button
                      label="Guardar cambios"
                      loadingText="Guardando..."
                      [loading]="loading()"
                    />
                  </div>
                </div>
              </form>
            </div>
          </div>
        </main>
      </div>
    </div>
  `,
})
export class EditProfileComponent {
  private fb = inject(FormBuilder);
  private profileService = inject(ProfileService);
  private tokenStorage = inject(TokenStorageService);
  private router = inject(Router);

  sidebarOpen = signal(false);
  loading = signal(false);
  errorMessage = signal('');
  successMessage = signal('');

  form = this.fb.group(
    {
      firstName: [this.tokenStorage.currentUser?.firstName ?? '', [Validators.required]],
      lastName: [this.tokenStorage.currentUser?.lastName ?? '', [Validators.required]],
      newPassword: [''],
      confirmPassword: [''],
    },
    { validators: passwordMatchValidator('newPassword', 'confirmPassword') },
  );

  onSubmit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const { firstName, lastName, newPassword } = this.form.value;
    const payload: { firstName?: string; lastName?: string; password?: string } = {
      firstName: firstName!,
      lastName: lastName!,
    };
    if (newPassword) payload.password = newPassword;

    this.loading.set(true);
    this.errorMessage.set('');

    this.profileService.updateProfile(payload).subscribe({
      next: () => {
        this.loading.set(false);
        this.successMessage.set('Perfil actualizado correctamente');
        setTimeout(() => this.router.navigate(['/profile']), 1500);
      },
      error: err => {
        this.loading.set(false);
        this.errorMessage.set(err?.error?.message ?? 'Error al actualizar el perfil');
      },
    });
  }
}
