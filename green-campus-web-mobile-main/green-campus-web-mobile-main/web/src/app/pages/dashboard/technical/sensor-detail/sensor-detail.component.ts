import { Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, ActivatedRoute } from '@angular/router';
import { TechnicalService } from '../../../../data/services/technical.service';
import { AppHeaderComponent } from '../../../../shared/components/app-header/app-header.component';
import { AppSidebarComponent } from '../../../../shared/components/app-sidebar/app-sidebar.component';
import { SensorGaugeComponent, GaugeType } from '../../../../shared/components/sensor-gauge/sensor-gauge.component';
import { IotNode } from '../../../../data/models/technical-data.model';

@Component({
  selector: 'app-sensor-detail',
  standalone: true,
  imports: [CommonModule, RouterLink, AppHeaderComponent, AppSidebarComponent, SensorGaugeComponent],
  template: `
    <div class="flex h-screen bg-surface overflow-hidden">
      <div class="hidden lg:flex lg:flex-shrink-0">
        <app-sidebar [isOpen]="true" (close)="sidebarOpen.set(false)" />
      </div>
      <app-sidebar [isOpen]="sidebarOpen()" (close)="sidebarOpen.set(false)" class="lg:hidden"/>

      <div class="flex-1 flex flex-col overflow-hidden min-w-0">
        <app-header (menuToggle)="sidebarOpen.set(!sidebarOpen())" />

        <main class="flex-1 overflow-y-auto p-4 lg:p-6">
          @if (loading()) {
            <div class="flex items-center justify-center h-64">
              <div class="flex flex-col items-center gap-3">
                <svg class="animate-spin h-8 w-8 text-accent-green" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                <p class="text-sm text-text-muted">Cargando datos del sensor...</p>
              </div>
            </div>
          } @else if (node()) {
            <div class="max-w-4xl mx-auto">
              <!-- Header -->
              <div class="flex items-center gap-3 mb-6">
                <a
                  routerLink="/devices"
                  class="p-2 rounded-lg text-text-secondary hover:bg-white hover:text-accent-green transition-colors"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                  </svg>
                </a>
                <div class="flex-1 min-w-0">
                  <div class="flex items-center gap-2 flex-wrap">
                    <h1 class="text-xl font-bold text-text-primary">{{ node()!.name }}</h1>
                    <span [ngClass]="getStatusBadge(node()!.status)">{{ node()!.status }}</span>
                  </div>
                  <p class="text-sm text-text-muted mt-0.5">{{ node()!.edificio }} · {{ node()!.planta }} · {{ node()!.location }}</p>
                </div>
              </div>

              <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <!-- Left column: Gauge + Controls -->
                <div class="space-y-5">
                  <!-- Gauge Card -->
                  <div class="card p-6">
                    <h2 class="text-sm font-semibold text-text-secondary uppercase tracking-wide mb-4">
                      Lectura actual — {{ getTypeLabel(node()!.type) }}
                    </h2>
                    <app-sensor-gauge
                      [type]="getGaugeType(node()!.type)"
                      [value]="getCurrentValue()"
                    />
                  </div>

                  <!-- Control Panel -->
                  <div class="card p-5">
                    <h2 class="text-sm font-semibold text-text-secondary uppercase tracking-wide mb-4">Panel de control</h2>
                    <div class="grid grid-cols-3 gap-3">
                      <button
                        (click)="controlAction('up')"
                        class="flex flex-col items-center gap-2 p-4 rounded-xl bg-surface hover:bg-accent-green-light hover:border-accent-green border border-border-color transition-all group"
                      >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-text-secondary group-hover:text-accent-green transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7"/>
                        </svg>
                        <span class="text-xs font-medium text-text-secondary group-hover:text-accent-green">Subir</span>
                      </button>
                      <button
                        (click)="controlAction('power')"
                        class="flex flex-col items-center gap-2 p-4 rounded-xl border transition-all group"
                        [ngClass]="isPowered() ? 'bg-red-50 border-red-200 hover:bg-red-100' : 'bg-green-50 border-green-200 hover:bg-green-100'"
                      >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 transition-colors" [ngClass]="isPowered() ? 'text-red-500' : 'text-accent-green'" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
                        </svg>
                        <span class="text-xs font-medium transition-colors" [ngClass]="isPowered() ? 'text-red-500' : 'text-accent-green'">
                          {{ isPowered() ? 'Apagar' : 'Encender' }}
                        </span>
                      </button>
                      <button
                        (click)="controlAction('down')"
                        class="flex flex-col items-center gap-2 p-4 rounded-xl bg-surface hover:bg-accent-green-light hover:border-accent-green border border-border-color transition-all group"
                      >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-text-secondary group-hover:text-accent-green transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
                        </svg>
                        <span class="text-xs font-medium text-text-secondary group-hover:text-accent-green">Bajar</span>
                      </button>
                    </div>
                    @if (controlFeedback()) {
                      <p class="text-xs text-accent-green text-center mt-3 font-medium">{{ controlFeedback() }}</p>
                    }
                  </div>
                </div>

                <!-- Right column: Health metrics + Chart -->
                <div class="space-y-5">
                  <!-- Health metrics -->
                  <div class="card p-5">
                    <h2 class="text-sm font-semibold text-text-secondary uppercase tracking-wide mb-4">Métricas de salud</h2>
                    <div class="space-y-4">
                      <!-- Battery -->
                      <div>
                        <div class="flex justify-between items-center mb-1.5">
                          <div class="flex items-center gap-2">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-text-muted" viewBox="0 0 24 24" fill="currentColor">
                              <path d="M15.67 4H14V2h-4v2H8.33C7.6 4 7 4.6 7 5.33v15.33C7 21.4 7.6 22 8.33 22h7.33c.74 0 1.34-.6 1.34-1.33V5.33C17 4.6 16.4 4 15.67 4z"/>
                            </svg>
                            <span class="text-sm text-text-secondary">Batería</span>
                          </div>
                          <span class="text-sm font-mono font-semibold" [ngClass]="getBatteryColor(node()!.battery)">
                            {{ node()!.battery }}%
                          </span>
                        </div>
                        <div class="h-2 bg-surface rounded-full overflow-hidden">
                          <div
                            class="h-full rounded-full transition-all duration-500"
                            [style.width.%]="node()!.battery"
                            [ngClass]="getBatteryBarColor(node()!.battery)"
                          ></div>
                        </div>
                      </div>

                      <!-- RSSI -->
                      <div class="flex items-center justify-between py-2 border-b border-border-color">
                        <div class="flex items-center gap-2">
                          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-text-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.111 16.404a5.5 5.5 0 017.778 0M12 20h.01m-7.08-7.071c3.904-3.905 10.236-3.905 14.141 0M1.394 9.393c5.857-5.857 15.355-5.857 21.213 0"/>
                          </svg>
                          <span class="text-sm text-text-secondary">RSSI</span>
                        </div>
                        <span class="text-sm font-mono font-semibold text-text-primary">
                          {{ node()!.rssi ?? 'N/D' }} dBm
                        </span>
                      </div>

                      <!-- Link Quality -->
                      <div class="flex items-center justify-between py-2 border-b border-border-color">
                        <div class="flex items-center gap-2">
                          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-text-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"/>
                          </svg>
                          <span class="text-sm text-text-secondary">Calidad de enlace</span>
                        </div>
                        <span class="text-sm font-mono font-semibold text-text-primary">
                          {{ node()!.linkQuality ?? 'N/D' }}%
                        </span>
                      </div>

                      <!-- Uptime -->
                      <div class="flex items-center justify-between py-2">
                        <div class="flex items-center gap-2">
                          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-text-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                          </svg>
                          <span class="text-sm text-text-secondary">Tiempo activo</span>
                        </div>
                        <span class="text-sm font-mono font-semibold text-text-primary">
                          {{ formatUptime(node()!.uptime) }}
                        </span>
                      </div>
                    </div>
                  </div>

                  <!-- Device Info -->
                  <div class="card p-5">
                    <h2 class="text-sm font-semibold text-text-secondary uppercase tracking-wide mb-4">Información del dispositivo</h2>
                    <div class="space-y-3">
                      <div class="flex justify-between">
                        <span class="text-sm text-text-muted">ID</span>
                        <span class="text-sm font-mono text-text-primary">{{ node()!.id }}</span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-sm text-text-muted">Tipo</span>
                        <span class="text-sm text-text-primary capitalize">{{ node()!.type }}</span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-sm text-text-muted">Edificio</span>
                        <span class="text-sm text-text-primary">{{ node()!.edificio }}</span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-sm text-text-muted">Planta</span>
                        <span class="text-sm text-text-primary">{{ node()!.planta }}</span>
                      </div>
                    </div>
                  </div>

                  <!-- Monthly Chart placeholder -->
                  <div class="card p-5">
                    <div class="flex items-center justify-between mb-4">
                      <h2 class="text-sm font-semibold text-text-secondary uppercase tracking-wide">Lecturas mensuales</h2>
                      <select class="text-xs border border-border-color rounded-lg px-2 py-1 text-text-secondary focus:outline-none focus:ring-1 focus:ring-accent-green">
                        <option>Mensual</option>
                        <option>Anual</option>
                      </select>
                    </div>
                    <!-- Placeholder chart bars -->
                    <div class="flex items-end justify-between gap-1 h-20">
                      @for (bar of chartBars; track $index) {
                        <div class="flex-1 flex flex-col items-center gap-1">
                          <div
                            class="w-full rounded-t-sm bg-accent-green opacity-60 transition-all"
                            [style.height.%]="bar"
                          ></div>
                        </div>
                      }
                    </div>
                    <div class="flex justify-between mt-1">
                      @for (month of chartMonths; track month) {
                        <span class="text-xs text-text-muted">{{ month }}</span>
                      }
                    </div>
                  </div>
                </div>
              </div>
            </div>
          } @else {
            <!-- Not found -->
            <div class="flex flex-col items-center justify-center h-64 gap-4">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-14 w-14 text-text-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
              <div class="text-center">
                <p class="text-lg font-semibold text-text-primary">Dispositivo no encontrado</p>
                <p class="text-sm text-text-muted mt-1">El ID solicitado no existe o fue eliminado</p>
              </div>
              <a routerLink="/devices" class="px-4 py-2 bg-accent-green text-white rounded-lg text-sm font-medium hover:bg-green-600 transition-colors">
                Volver a la búsqueda
              </a>
            </div>
          }
        </main>
      </div>
    </div>
  `,
})
export class SensorDetailComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private technicalService = inject(TechnicalService);

  sidebarOpen = signal(false);
  loading = signal(false);
  node = signal<IotNode | null>(null);
  isPowered = signal(true);
  controlFeedback = signal('');

  chartBars = [65, 72, 58, 80, 68, 90, 75, 85, 70, 60, 88, 95];
  chartMonths = ['E', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id')!;
    this.loadNode(id);
  }

  loadNode(id: string): void {
    this.loading.set(true);
    this.technicalService.getNodeById(id).subscribe({
      next: data => {
        this.node.set(data);
        this.loading.set(false);
      },
      error: () => {
        // Fall back to mock data
        const mock = this.technicalService.getMockNodes().find(n => n.id === id) ?? null;
        this.node.set(mock);
        this.loading.set(false);
      },
    });
  }

  controlAction(action: 'up' | 'down' | 'power'): void {
    const messages: Record<string, string> = {
      up: 'Incrementando valor...',
      down: 'Decrementando valor...',
      power: this.isPowered() ? 'Apagando dispositivo...' : 'Encendiendo dispositivo...',
    };
    if (action === 'power') this.isPowered.set(!this.isPowered());
    this.controlFeedback.set(messages[action]);
    setTimeout(() => this.controlFeedback.set(''), 2000);
  }

  getCurrentValue(): number {
    const n = this.node();
    if (!n?.lastTelemetry) return 0;
    const t = n.lastTelemetry;
    switch (n.type) {
      case 'temperatura': return t.temperature ?? 0;
      case 'humedad': return t.humidity ?? 0;
      case 'calidadAire': return t.co2 ?? 0;
      case 'energia': return t.energy ?? 0;
      default:
        // For Raspberry Pi / Arduino, return temperature if available
        return t.temperature ?? t.humidity ?? t.co2 ?? 0;
    }
  }

  getGaugeType(type: string): GaugeType {
    const map: Record<string, GaugeType> = {
      temperatura: 'temperatura',
      humedad: 'humedad',
      calidadAire: 'calidadAire',
      energia: 'energia',
    };
    return map[type] ?? 'temperatura';
  }

  getTypeLabel(type: string): string {
    const map: Record<string, string> = {
      temperatura: 'Temperatura',
      humedad: 'Humedad',
      calidadAire: 'Calidad del Aire (CO₂)',
      energia: 'Energía',
      'Raspberry Pi': 'Temperatura',
      Arduino: 'Temperatura',
    };
    return map[type] ?? type;
  }

  getStatusBadge(status: string): string {
    switch (status) {
      case 'ONLINE': return 'badge-online';
      case 'STANDBY': return 'badge-standby';
      case 'OFFLINE': return 'badge-offline';
      default: return 'badge-standby';
    }
  }

  getBatteryColor(battery: number): string {
    if (battery >= 60) return 'text-accent-green';
    if (battery >= 30) return 'text-yellow-500';
    return 'text-red-500';
  }

  getBatteryBarColor(battery: number): string {
    if (battery >= 60) return 'bg-accent-green';
    if (battery >= 30) return 'bg-yellow-400';
    return 'bg-red-500';
  }

  formatUptime(minutes?: number): string {
    if (minutes === undefined || minutes === 0) return 'Inactivo';
    if (minutes < 60) return `${minutes}m`;
    if (minutes < 1440) return `${Math.floor(minutes / 60)}h ${minutes % 60}m`;
    const days = Math.floor(minutes / 1440);
    const hours = Math.floor((minutes % 1440) / 60);
    return `${days}d ${hours}h`;
  }
}
