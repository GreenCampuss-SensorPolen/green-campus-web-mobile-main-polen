import { Component, inject, signal, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { FacilityManagementService } from '../../../data/services/facility-management.service';
import { AppHeaderComponent } from '../../../shared/components/app-header/app-header.component';
import { AppSidebarComponent } from '../../../shared/components/app-sidebar/app-sidebar.component';
import { HabitabilityStats, ZoneConfort, PreventiveTask } from '../../../data/models/facility-management-data.model';
import { APP_CONFIG } from '../../../core/config/app-config';

@Component({
  selector: 'app-facility-management',
  standalone: true,
  imports: [CommonModule, AppHeaderComponent, AppSidebarComponent],
  template: `
    <div class="flex h-screen bg-surface overflow-hidden">
      <!-- Sidebar -->
      <div class="hidden lg:flex lg:flex-shrink-0">
        <app-sidebar [isOpen]="true" (close)="sidebarOpen.set(false)" />
      </div>
      <app-sidebar [isOpen]="sidebarOpen()" (close)="sidebarOpen.set(false)" class="lg:hidden"/>

      <div class="flex-1 flex flex-col overflow-hidden min-w-0">
        <app-header (menuToggle)="sidebarOpen.set(!sidebarOpen())" />

        <main class="flex-1 overflow-y-auto p-4 lg:p-6">
          <!-- Page Header -->
          <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-6">
            <div>
              <h1 class="text-2xl font-bold text-text-primary">Gestión de Instalaciones</h1>
              <p class="text-sm text-text-secondary mt-0.5">Monitoreo ambiental en tiempo real</p>
            </div>
            <div class="flex items-center gap-2">
              @if (lastUpdated()) {
                <span class="text-xs text-text-muted">
                  Actualizado: {{ lastUpdated() }}
                </span>
              }
              <button
                (click)="loadData()"
                [disabled]="loading()"
                class="p-2 rounded-lg bg-white border border-border-color text-text-secondary hover:text-accent-green hover:border-accent-green transition-colors disabled:opacity-50"
                aria-label="Refresh"
              >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" [class.animate-spin]="loading()" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                </svg>
              </button>
            </div>
          </div>

          <!-- Error state -->
          @if (errorMessage()) {
            <div class="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg flex items-center justify-between">
              <p class="text-sm text-red-600">{{ errorMessage() }}</p>
              <button (click)="loadData()" class="text-sm text-red-700 font-medium hover:underline">Reintentar</button>
            </div>
          }

          <!-- Stats Cards -->
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
            <!-- Temperature -->
            <div class="stat-card">
              <div class="flex items-center justify-between">
                <span class="text-sm font-medium text-text-secondary">Temperatura promedio</span>
                <div class="w-8 h-8 rounded-lg bg-orange-50 flex items-center justify-center">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-orange-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                  </svg>
                </div>
              </div>
              @if (loading() && !habitability()) {
                <div class="h-8 bg-surface animate-pulse rounded mt-1"></div>
              } @else {
                <p class="font-mono-value">
                  {{ habitability()?.averageTemp?.toFixed(1) ?? '--' }}<span class="text-base text-text-muted font-normal ml-1">°C</span>
                </p>
              }
              <p class="text-xs text-text-muted">Promedio del campus</p>
            </div>

            <!-- Humidity -->
            <div class="stat-card">
              <div class="flex items-center justify-between">
                <span class="text-sm font-medium text-text-secondary">Humedad</span>
                <div class="w-8 h-8 rounded-lg bg-blue-50 flex items-center justify-center">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-blue-500" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 2.69l5.66 5.66a8 8 0 11-11.31 0z"/>
                  </svg>
                </div>
              </div>
              @if (loading() && !habitability()) {
                <div class="h-8 bg-surface animate-pulse rounded mt-1"></div>
              } @else {
                <p class="font-mono-value">
                  {{ habitability()?.averageHumidity?.toFixed(1) ?? '--' }}<span class="text-base text-text-muted font-normal ml-1">%</span>
                </p>
              }
              <p class="text-xs text-text-muted">Humedad relativa</p>
            </div>

            <!-- CO2 -->
            <div class="stat-card">
              <div class="flex items-center justify-between">
                <span class="text-sm font-medium text-text-secondary">CO₂</span>
                <div class="w-8 h-8 rounded-lg bg-accent-green-light flex items-center justify-center">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-accent-green" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064"/>
                  </svg>
                </div>
              </div>
              @if (loading() && !habitability()) {
                <div class="h-8 bg-surface animate-pulse rounded mt-1"></div>
              } @else {
                <p class="font-mono-value">
                  {{ habitability()?.averageCo2?.toFixed(0) ?? '--' }}<span class="text-base text-text-muted font-normal ml-1">ppm</span>
                </p>
              }
              <p class="text-xs text-text-muted">Calidad del aire</p>
            </div>
          </div>

          <div class="grid grid-cols-1 xl:grid-cols-2 gap-6">
            <!-- Zones Table -->
            <div class="card overflow-hidden">
              <div class="px-5 py-4 border-b border-border-color flex items-center justify-between">
                <h2 class="font-semibold text-text-primary">Zonas de Confort</h2>
                <span class="text-xs text-text-muted">{{ zones().length }} zonas</span>
              </div>

              @if (loading() && zones().length === 0) {
                <div class="p-5 space-y-3">
                  @for (i of [1,2,3]; track i) {
                    <div class="h-12 bg-surface animate-pulse rounded-lg"></div>
                  }
                </div>
              } @else if (zones().length === 0) {
                <div class="p-8 text-center text-text-muted text-sm">No hay zonas disponibles</div>
              } @else {
                <div class="overflow-x-auto">
                  <table class="w-full text-sm">
                    <thead>
                      <tr class="bg-surface text-text-muted text-xs uppercase tracking-wide">
                        <th class="px-5 py-3 text-left font-medium">Zona</th>
                        <th class="px-3 py-3 text-center font-medium">Estado</th>
                        <th class="px-3 py-3 text-right font-medium">Temp.</th>
                        <th class="px-3 py-3 text-right font-medium">Hum.</th>
                      </tr>
                    </thead>
                    <tbody class="divide-y divide-border-color">
                      @for (zone of zones(); track zone.id) {
                        <tr class="hover:bg-surface/50 transition-colors">
                          <td class="px-5 py-3 font-medium text-text-primary">{{ zone.name }}</td>
                          <td class="px-3 py-3 text-center">
                            <span [ngClass]="getZoneBadgeClass(zone.status)">
                              {{ zone.status }}
                            </span>
                          </td>
                          <td class="px-3 py-3 text-right font-mono text-text-primary">{{ zone.temp.toFixed(1) }}°C</td>
                          <td class="px-3 py-3 text-right font-mono text-text-primary">{{ zone.humidity.toFixed(0) }}%</td>
                        </tr>
                      }
                    </tbody>
                  </table>
                </div>
              }
            </div>

            <!-- Preventive Tasks -->
            <div class="card overflow-hidden">
              <div class="px-5 py-4 border-b border-border-color flex items-center justify-between">
                <h2 class="font-semibold text-text-primary">Tareas Preventivas</h2>
                <span class="text-xs text-text-muted">{{ tasks().length }} tareas</span>
              </div>

              @if (loading() && tasks().length === 0) {
                <div class="p-5 space-y-3">
                  @for (i of [1,2,3]; track i) {
                    <div class="h-16 bg-surface animate-pulse rounded-lg"></div>
                  }
                </div>
              } @else if (tasks().length === 0) {
                <div class="p-8 text-center text-text-muted text-sm">No hay tareas pendientes</div>
              } @else {
                <div class="divide-y divide-border-color">
                  @for (task of tasks(); track task.id) {
                    <div class="px-5 py-4 hover:bg-surface/50 transition-colors">
                      <div class="flex items-start justify-between gap-3">
                        <div class="flex-1 min-w-0">
                          <p class="text-sm font-medium text-text-primary truncate">{{ task.title }}</p>
                          <div class="flex items-center gap-1.5 mt-1">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5 text-text-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                            </svg>
                            <p class="text-xs text-text-muted truncate">{{ task.location }}</p>
                          </div>
                        </div>
                        <div class="flex flex-col items-end gap-1.5 flex-shrink-0">
                          <span [ngClass]="getPriorityBadgeClass(task.priority)">{{ task.priority }}</span>
                          <span
                            class="text-xs font-medium"
                            [class]="task.daysRemaining <= 3 ? 'text-red-600' : task.daysRemaining <= 7 ? 'text-yellow-600' : 'text-text-muted'"
                          >
                            {{ task.daysRemaining }}d restantes
                          </span>
                        </div>
                      </div>
                    </div>
                  }
                </div>
              }
            </div>
          </div>
        </main>
      </div>
    </div>
  `,
})
export class FacilityManagementComponent implements OnInit, OnDestroy {
  private facilityService = inject(FacilityManagementService);

  sidebarOpen = signal(false);
  loading = signal(false);
  errorMessage = signal('');
  habitability = signal<HabitabilityStats | null>(null);
  zones = signal<ZoneConfort[]>([]);
  tasks = signal<PreventiveTask[]>([]);
  lastUpdated = signal('');

  private refreshInterval?: ReturnType<typeof setInterval>;

  ngOnInit(): void {
    this.loadData();
    this.refreshInterval = setInterval(() => this.loadData(), APP_CONFIG.refreshInterval);
  }

  ngOnDestroy(): void {
    clearInterval(this.refreshInterval);
  }

  loadData(): void {
    this.loading.set(true);
    this.errorMessage.set('');

    // Try API first, fallback to mock data
    this.facilityService.getHabitability().subscribe({
      next: data => {
        this.habitability.set(data);
        this.setLastUpdated();
      },
      error: () => {
        // Use mock data when API is unavailable
        this.habitability.set(this.facilityService.getMockHabitability());
        this.setLastUpdated();
      },
    });

    this.facilityService.getZones().subscribe({
      next: data => { this.zones.set(data); this.loading.set(false); },
      error: () => {
        this.zones.set(this.facilityService.getMockZones());
        this.loading.set(false);
      },
    });

    this.facilityService.getTasks().subscribe({
      next: data => this.tasks.set(data),
      error: () => this.tasks.set(this.facilityService.getMockTasks()),
    });
  }

  private setLastUpdated(): void {
    const now = new Date();
    this.lastUpdated.set(now.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit' }));
  }

  getZoneBadgeClass(status: string): string {
    switch (status) {
      case 'OPTIMO': return 'badge-online';
      case 'REGULAR': return 'badge-standby';
      case 'CRITICO': return 'badge-offline';
      default: return 'badge-standby';
    }
  }

  getPriorityBadgeClass(priority: string): string {
    switch (priority) {
      case 'CRITICAL': return 'badge-critical';
      case 'MEDIUM': return 'badge-medium';
      case 'LOW': return 'badge-low';
      default: return 'badge-low';
    }
  }
}
