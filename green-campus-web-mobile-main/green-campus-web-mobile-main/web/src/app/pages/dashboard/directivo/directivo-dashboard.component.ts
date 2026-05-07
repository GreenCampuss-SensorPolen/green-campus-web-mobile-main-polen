import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AppHeaderComponent } from '../../../shared/components/app-header/app-header.component';
import { AppSidebarComponent } from '../../../shared/components/app-sidebar/app-sidebar.component';

@Component({
  selector: 'app-directivo-dashboard',
  standalone: true,
  imports: [CommonModule, AppHeaderComponent, AppSidebarComponent],
  template: `
    <div class="flex h-screen bg-surface overflow-hidden">
      <div class="hidden lg:flex lg:flex-shrink-0">
        <app-sidebar [isOpen]="true" (close)="sidebarOpen.set(false)" />
      </div>
      <app-sidebar [isOpen]="sidebarOpen()" (close)="sidebarOpen.set(false)" class="lg:hidden"/>

      <div class="flex-1 flex flex-col overflow-hidden">
        <app-header (menuToggle)="sidebarOpen.set(!sidebarOpen())" />

        <main class="flex-1 overflow-y-auto flex items-center justify-center p-8">
          <div class="text-center max-w-md">
            <!-- Construction illustration -->
            <div class="w-24 h-24 bg-yellow-50 rounded-full flex items-center justify-center mx-auto mb-6">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 text-yellow-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                  d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z"/>
              </svg>
            </div>

            <h1 class="text-2xl font-bold text-text-primary mb-3">Panel Directivo</h1>
            <p class="text-text-secondary mb-2">Esta sección está en construcción.</p>
            <p class="text-sm text-text-muted mb-8">
              Próximamente dispondrá de reportes ejecutivos, métricas de sostenibilidad y análisis de tendencias para la toma de decisiones estratégicas.
            </p>

            <!-- Feature preview cards -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 text-left">
              @for (feature of features; track feature.title) {
                <div class="card p-4 opacity-60">
                  <div class="flex items-center gap-2 mb-2">
                    <div class="w-7 h-7 rounded-lg bg-accent-green-light flex items-center justify-center">
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-accent-green" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" [attr.d]="feature.icon"/>
                      </svg>
                    </div>
                    <span class="text-xs font-semibold text-text-primary">{{ feature.title }}</span>
                  </div>
                  <p class="text-xs text-text-muted">{{ feature.description }}</p>
                </div>
              }
            </div>

            <div class="mt-8 inline-flex items-center gap-2 px-4 py-2 bg-yellow-50 border border-yellow-200 rounded-full">
              <div class="w-2 h-2 rounded-full bg-yellow-400"></div>
              <span class="text-xs text-yellow-700 font-medium">En desarrollo</span>
            </div>
          </div>
        </main>
      </div>
    </div>
  `,
})
export class DirectivoDashboardComponent {
  sidebarOpen = signal(false);

  features = [
    {
      title: 'Reportes Ejecutivos',
      description: 'Informes periódicos de consumo energético y calidad ambiental.',
      icon: 'M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z',
    },
    {
      title: 'Métricas de Sostenibilidad',
      description: 'Indicadores clave de rendimiento ambiental del campus.',
      icon: 'M13 7h8m0 0v8m0-8l-8 8-4-4-6 6',
    },
    {
      title: 'Análisis de Tendencias',
      description: 'Visualización de datos históricos y predicciones.',
      icon: 'M16 8v8m-4-5v5m-4-2v2m-2 4h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z',
    },
    {
      title: 'Alertas Estratégicas',
      description: 'Notificaciones críticas para decisiones inmediatas.',
      icon: 'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z',
    },
  ];
}
