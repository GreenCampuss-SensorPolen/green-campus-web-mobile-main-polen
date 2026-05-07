import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AppHeaderComponent } from '../../shared/components/app-header/app-header.component';
import { AppSidebarComponent } from '../../shared/components/app-sidebar/app-sidebar.component';

@Component({
  selector: 'app-notifications',
  standalone: true,
  imports: [CommonModule, AppHeaderComponent, AppSidebarComponent],
  template: `
    <div class="flex h-screen bg-surface overflow-hidden">
      <app-sidebar [isOpen]="sidebarOpen()" (close)="sidebarOpen.set(false)" class="hidden lg:flex"/>
      <app-sidebar [isOpen]="sidebarOpen()" (close)="sidebarOpen.set(false)" class="flex lg:hidden"/>

      <div class="flex-1 flex flex-col overflow-hidden">
        <app-header (menuToggle)="sidebarOpen.set(!sidebarOpen())" />

        <main class="flex-1 overflow-y-auto p-4 lg:p-8">
          <div class="max-w-2xl mx-auto">
            <h1 class="text-2xl font-bold text-text-primary mb-6">Notificaciones</h1>

            <!-- Empty state -->
            <div class="card p-12 flex flex-col items-center justify-center text-center">
              <div class="w-20 h-20 bg-surface rounded-full flex items-center justify-center mb-5">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 text-text-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                    d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
                </svg>
              </div>
              <h3 class="text-lg font-semibold text-text-primary mb-2">No hay notificaciones</h3>
              <p class="text-sm text-text-secondary max-w-xs">
                Cuando recibas alertas del sistema aparecerán aquí.
              </p>
            </div>
          </div>
        </main>
      </div>
    </div>
  `,
})
export class NotificationsComponent {
  sidebarOpen = signal(false);
}
