import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { TokenStorageService } from '../../data/services/token-storage.service';
import { AppHeaderComponent } from '../../shared/components/app-header/app-header.component';
import { AppSidebarComponent } from '../../shared/components/app-sidebar/app-sidebar.component';
import { ROLE_LABELS } from '../../core/constants/user-roles';
import { signal } from '@angular/core';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, RouterLink, AppHeaderComponent, AppSidebarComponent],
  template: `
    <div class="flex h-screen bg-surface overflow-hidden">
      <!-- Sidebar -->
      <app-sidebar [isOpen]="sidebarOpen()" (close)="sidebarOpen.set(false)" class="hidden lg:flex"/>
      <app-sidebar [isOpen]="sidebarOpen()" (close)="sidebarOpen.set(false)" class="flex lg:hidden"/>

      <div class="flex-1 flex flex-col overflow-hidden">
        <app-header (menuToggle)="sidebarOpen.set(!sidebarOpen())" />

        <main class="flex-1 overflow-y-auto p-4 lg:p-8">
          <div class="max-w-2xl mx-auto">
            <!-- Page title -->
            <div class="flex items-center justify-between mb-6">
              <h1 class="text-2xl font-bold text-text-primary">Mi Perfil</h1>
              <a
                routerLink="/profile/edit"
                class="inline-flex items-center gap-2 px-4 py-2 bg-accent-green text-white rounded-lg text-sm font-medium hover:bg-green-600 transition-colors"
              >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                </svg>
                Editar
              </a>
            </div>

            <!-- Profile card -->
            <div class="card p-8">
              <!-- Avatar section -->
              <div class="flex flex-col items-center mb-8 pb-8 border-b border-border-color">
                @if (user?.profileImageUrl) {
                  <img
                    [src]="user?.profileImageUrl"
                    alt="Profile"
                    class="w-24 h-24 rounded-full object-cover border-4 border-accent-green shadow-md"
                  />
                } @else {
                  <div class="w-24 h-24 rounded-full bg-accent-green-light border-4 border-accent-green shadow-md flex items-center justify-center">
                    <span class="text-3xl font-bold text-accent-green">{{ initials }}</span>
                  </div>
                }
                <h2 class="mt-4 text-xl font-bold text-text-primary">{{ user?.firstName }} {{ user?.lastName }}</h2>
                <span
                  class="mt-2 inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-accent-green-light text-accent-green"
                >
                  {{ roleLabel }}
                </span>
              </div>

              <!-- Info rows -->
              <div class="space-y-5">
                <div class="flex items-start gap-4">
                  <div class="w-10 h-10 rounded-lg bg-surface flex items-center justify-center flex-shrink-0">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-text-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                    </svg>
                  </div>
                  <div>
                    <p class="text-xs font-medium text-text-muted uppercase tracking-wide">Correo electrónico</p>
                    <p class="text-sm text-text-primary mt-0.5">{{ user?.email }}</p>
                  </div>
                </div>

                <div class="flex items-start gap-4">
                  <div class="w-10 h-10 rounded-lg bg-surface flex items-center justify-center flex-shrink-0">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-text-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                    </svg>
                  </div>
                  <div>
                    <p class="text-xs font-medium text-text-muted uppercase tracking-wide">Nombre completo</p>
                    <p class="text-sm text-text-primary mt-0.5">{{ user?.firstName }} {{ user?.lastName }}</p>
                  </div>
                </div>

                <div class="flex items-start gap-4">
                  <div class="w-10 h-10 rounded-lg bg-surface flex items-center justify-center flex-shrink-0">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-text-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
                    </svg>
                  </div>
                  <div>
                    <p class="text-xs font-medium text-text-muted uppercase tracking-wide">Rol</p>
                    <p class="text-sm text-text-primary mt-0.5">{{ roleLabel }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  `,
})
export class ProfileComponent {
  private tokenStorage = inject(TokenStorageService);
  sidebarOpen = signal(false);

  get user() {
    return this.tokenStorage.currentUser;
  }

  get initials(): string {
    const u = this.user;
    if (!u) return '?';
    return `${u.firstName?.charAt(0) ?? ''}${u.lastName?.charAt(0) ?? ''}`.toUpperCase();
  }

  get roleLabel(): string {
    return ROLE_LABELS[this.user?.role ?? ''] ?? this.user?.role ?? '';
  }
}
