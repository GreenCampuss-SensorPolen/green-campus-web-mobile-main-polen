import { Component, inject, signal, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { forkJoin } from 'rxjs';
import { TechnicalService } from '../../../data/services/technical.service';
import { AppHeaderComponent } from '../../../shared/components/app-header/app-header.component';
import { AppSidebarComponent } from '../../../shared/components/app-sidebar/app-sidebar.component';
import { IotNode, MonthlyReading } from '../../../data/models/technical-data.model';
import { APP_CONFIG } from '../../../core/config/app-config';

@Component({
  selector: 'app-technical-dashboard',
  standalone: true,
  imports: [CommonModule, RouterLink, AppHeaderComponent, AppSidebarComponent],
  template: `
    <div class="flex h-screen bg-surface overflow-hidden">
      <div class="hidden lg:flex lg:flex-shrink-0">
        <app-sidebar [isOpen]="true" (close)="sidebarOpen.set(false)" />
      </div>
      <app-sidebar [isOpen]="sidebarOpen()" (close)="sidebarOpen.set(false)" class="lg:hidden"/>

      <div class="flex-1 flex flex-col overflow-hidden min-w-0">
        <app-header (menuToggle)="sidebarOpen.set(!sidebarOpen())" />

        <main class="flex-1 overflow-y-auto p-4 lg:p-6">
          <!-- Page header -->
          <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-6">
            <div>
              <h1 class="text-2xl font-bold text-text-primary">Panel Técnico</h1>
              <p class="text-sm text-text-secondary mt-0.5">Gestión de nodos IoT</p>
            </div>
            <div class="flex items-center gap-2">
              @if (lastUpdated()) {
                <span class="text-xs text-text-muted">Actualizado: {{ lastUpdated() }}</span>
              }
              <button
                (click)="loadData()"
                [disabled]="loading()"
                class="p-2 rounded-lg bg-white border border-border-color text-text-secondary hover:text-accent-green hover:border-accent-green transition-colors disabled:opacity-50"
              >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" [class.animate-spin]="loading()" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                </svg>
              </button>
              <a
                routerLink="/devices"
                class="inline-flex items-center gap-2 px-4 py-2 bg-accent-green text-white rounded-lg text-sm font-medium hover:bg-green-600 transition-colors"
              >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                </svg>
                Buscar dispositivo
              </a>
            </div>
          </div>

          <!-- Summary cards -->
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
            <div class="stat-card">
              <div class="flex items-center justify-between">
                <span class="text-sm font-medium text-text-secondary">Total nodos</span>
                <div class="w-8 h-8 rounded-lg bg-surface flex items-center justify-center">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-text-secondary" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z"/>
                  </svg>
                </div>
              </div>
              <p class="font-mono-value">{{ nodes().length }}</p>
              <p class="text-xs text-text-muted">Dispositivos registrados</p>
            </div>

            <div class="stat-card">
              <div class="flex items-center justify-between">
                <span class="text-sm font-medium text-text-secondary">En línea</span>
                <div class="w-2.5 h-2.5 rounded-full bg-status-online"></div>
              </div>
              <p class="font-mono-value text-status-online">{{ onlineCount() }}</p>
              <p class="text-xs text-text-muted">Activos ahora</p>
            </div>

            <div class="stat-card">
              <div class="flex items-center justify-between">
                <span class="text-sm font-medium text-text-secondary">Alertas</span>
                <div class="w-2.5 h-2.5 rounded-full bg-status-offline"></div>
              </div>
              <p class="font-mono-value text-status-offline">{{ offlineCount() }}</p>
              <p class="text-xs text-text-muted">Fuera de línea</p>
            </div>
          </div>

          <!-- Sensor Readings -->
          <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
            <div class="card p-4">
              <p class="text-xs text-text-muted mb-1">Temp. promedio</p>
              <p class="font-mono text-xl font-semibold text-orange-500">
                {{ avgTemp() }}<span class="text-sm font-normal">°C</span>
              </p>
            </div>
            <div class="card p-4">
              <p class="text-xs text-text-muted mb-1">Humedad prom.</p>
              <p class="font-mono text-xl font-semibold text-blue-500">
                {{ avgHumidity() }}<span class="text-sm font-normal">%</span>
              </p>
            </div>
            <div class="card p-4">
              <p class="text-xs text-text-muted mb-1">CO₂ promedio</p>
              <p class="font-mono text-xl font-semibold text-accent-green">
                {{ avgCo2() }}<span class="text-sm font-normal">ppm</span>
              </p>
            </div>
            <div class="card p-4">
              <p class="text-xs text-text-muted mb-1">Energía total</p>
              <p class="font-mono text-xl font-semibold text-purple-500">
                {{ totalEnergy() }}<span class="text-sm font-normal">kWh</span>
              </p>
            </div>
          </div>

          <!-- IoT Devices list -->
          <div class="card overflow-hidden">
            <div class="px-5 py-4 border-b border-border-color flex items-center justify-between">
              <h2 class="font-semibold text-text-primary">Hardware IoT</h2>
              <span class="text-xs text-text-muted">{{ hardwareNodes().length }} dispositivos</span>
            </div>

            @if (loading() && nodes().length === 0) {
              <div class="p-5 space-y-3">
                @for (i of [1,2,3,4]; track i) {
                  <div class="h-16 bg-surface animate-pulse rounded-lg"></div>
                }
              </div>
            } @else {
              <div class="divide-y divide-border-color">
                @for (node of hardwareNodes(); track node.id) {
                  <a
                    [routerLink]="['/devices', node.id]"
                    class="flex items-center gap-4 px-5 py-4 hover:bg-surface/60 transition-colors cursor-pointer"
                  >
                    <!-- Status indicator -->
                    <div class="flex-shrink-0">
                      <div
                        class="w-10 h-10 rounded-xl flex items-center justify-center"
                        [ngClass]="getNodeIconBg(node.status)"
                      >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" [ngClass]="getNodeIconColor(node.status)" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z"/>
                        </svg>
                      </div>
                    </div>

                    <!-- Info -->
                    <div class="flex-1 min-w-0">
                      <div class="flex items-center gap-2">
                        <p class="text-sm font-medium text-text-primary truncate">{{ node.name }}</p>
                        <span [ngClass]="getStatusBadge(node.status)">{{ node.status }}</span>
                      </div>
                      <div class="flex items-center gap-3 mt-0.5">
                        <span class="text-xs text-text-muted">{{ node.edificio }}</span>
                        <span class="text-xs text-text-muted">·</span>
                        <span class="text-xs text-text-muted">{{ node.planta }}</span>
                        <span class="text-xs text-text-muted">·</span>
                        <span class="text-xs text-text-muted capitalize">{{ node.type }}</span>
                      </div>
                    </div>

                    <!-- Battery + telemetry -->
                    <div class="flex-shrink-0 flex flex-col items-end gap-1">
                      <div class="flex items-center gap-1">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" [ngClass]="getBatteryColor(node.battery)" viewBox="0 0 24 24" fill="currentColor">
                          <path d="M15.67 4H14V2h-4v2H8.33C7.6 4 7 4.6 7 5.33v15.33C7 21.4 7.6 22 8.33 22h7.33c.74 0 1.34-.6 1.34-1.33V5.33C17 4.6 16.4 4 15.67 4z"/>
                        </svg>
                        <span class="text-xs font-mono" [ngClass]="getBatteryColor(node.battery)">{{ node.battery }}%</span>
                      </div>
                      @if (node.lastTelemetry?.temperature !== undefined) {
                        <span class="text-xs font-mono text-text-muted">{{ node.lastTelemetry?.temperature?.toFixed(1) }}°C</span>
                      }
                    </div>

                    <!-- Arrow -->
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-text-muted flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                    </svg>
                  </a>
                }
              </div>
            }
          </div>
        </main>
      </div>
    </div>
  `,
})
export class TechnicalDashboardComponent implements OnInit, OnDestroy {
  private technicalService = inject(TechnicalService);

  sidebarOpen = signal(false);
  loading = signal(false);
  nodes = signal<IotNode[]>([]);
  lastUpdated = signal('');

  // Sensor readings — same approach as Flutter: monthly endpoint, extract today's value
  avgTemp = signal<string>('--');
  avgHumidity = signal<string>('--');
  avgCo2 = signal<string>('--');
  totalEnergy = signal<string>('--');

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
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth() + 1;
    const today = now.getDate();

    forkJoin({
      nodes:       this.technicalService.getNodes(),
      temperatura: this.technicalService.getMonthlyReadings('TEMPERATURA', year, month),
      humedad:     this.technicalService.getMonthlyReadings('HUMEDAD', year, month),
      co2:         this.technicalService.getMonthlyReadings('CO2', year, month),
    }).subscribe({
      next: ({ nodes, temperatura, humedad, co2 }) => {
        this.nodes.set(nodes);
        // Extract ONLY today's daily average — mirrors Flutter's _extractTodayValue
        this.avgTemp.set(this.extractTodayValue(temperatura, today, 1) ?? '--');
        this.avgHumidity.set(this.extractTodayValue(humedad, today, 1) ?? '--');
        this.avgCo2.set(this.extractTodayValue(co2, today, 0) ?? '--');
        this.totalEnergy.set(this.calcEnergy(nodes));
        this.loading.set(false);
        this.setLastUpdated();
      },
      error: () => {
        // Safety fallback: use mock data if forkJoin itself errors
        const nodes = this.technicalService.getMockNodes();
        this.nodes.set(nodes);
        this.avgTemp.set(this.extractTodayValue(this.technicalService.getMockMonthlyReadings('TEMPERATURA'), today, 1) ?? '--');
        this.avgHumidity.set(this.extractTodayValue(this.technicalService.getMockMonthlyReadings('HUMEDAD'), today, 1) ?? '--');
        this.avgCo2.set(this.extractTodayValue(this.technicalService.getMockMonthlyReadings('CO2'), today, 0) ?? '--');
        this.totalEnergy.set(this.calcEnergy(nodes));
        this.loading.set(false);
        this.setLastUpdated();
      },
    });
  }

  /** Replicates Flutter's _extractTodayValue: compares day as string, parses value as float */
  private extractTodayValue(
    readings: MonthlyReading[],
    today: number,
    decimals: number,
  ): string | null {
    const todayStr = today.toString();
    const entry = readings.find(r => r.day.toString() === todayStr);
    if (entry == null) return null;
    const parsed = parseFloat(entry.value.toString());
    if (isNaN(parsed)) return null;
    return decimals === 0 ? Math.round(parsed).toString() : parsed.toFixed(decimals);
  }

  private calcEnergy(nodes: IotNode[]): string {
    const vals = nodes
      .map(n => n.lastTelemetry?.energy)
      .filter((v): v is number => v !== undefined);
    return vals.length ? vals.reduce((a, b) => a + b, 0).toFixed(1) : '--';
  }

  private setLastUpdated(): void {
    const now = new Date();
    this.lastUpdated.set(now.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit' }));
  }

  private static readonly HARDWARE_TYPES = ['Raspberry', 'Arduino'];

  get hardwareNodes() {
    return signal(
      this.nodes().filter(n =>
        TechnicalDashboardComponent.HARDWARE_TYPES.some(t =>
          n.type.toLowerCase().includes(t.toLowerCase())
        )
      )
    );
  }

  get onlineCount() {
    return signal(this.nodes().filter(n => n.status === 'ONLINE').length);
  }

  get offlineCount() {
    return signal(
    this.nodes().filter(n => ['OFFLINE', 'STANDBY'].includes(n.status)).length
  );
  }

  getStatusBadge(status: string): string {
    switch (status) {
      case 'ONLINE': return 'badge-online';
      case 'STANDBY': return 'badge-standby';
      case 'OFFLINE': return 'badge-offline';
      default: return 'badge-standby';
    }
  }

  getNodeIconBg(status: string): string {
    switch (status) {
      case 'ONLINE': return 'bg-green-50';
      case 'STANDBY': return 'bg-yellow-50';
      case 'OFFLINE': return 'bg-red-50';
      default: return 'bg-surface';
    }
  }

  getNodeIconColor(status: string): string {
    switch (status) {
      case 'ONLINE': return 'text-accent-green';
      case 'STANDBY': return 'text-yellow-500';
      case 'OFFLINE': return 'text-red-500';
      default: return 'text-text-muted';
    }
  }

  getBatteryColor(battery: number): string {
    if (battery >= 60) return 'text-accent-green';
    if (battery >= 30) return 'text-yellow-500';
    return 'text-red-500';
  }
}
