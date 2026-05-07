import { Component, inject, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormControl } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { TechnicalService } from '../../../../data/services/technical.service';
import { AppHeaderComponent } from '../../../../shared/components/app-header/app-header.component';
import { AppSidebarComponent } from '../../../../shared/components/app-sidebar/app-sidebar.component';
import { IotNode } from '../../../../data/models/technical-data.model';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';

@Component({
  selector: 'app-device-id-search',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink, AppHeaderComponent, AppSidebarComponent],
  template: `
    <div class="flex h-screen bg-surface overflow-hidden">
      <div class="hidden lg:flex lg:flex-shrink-0">
        <app-sidebar [isOpen]="true" (close)="sidebarOpen.set(false)" />
      </div>
      <app-sidebar [isOpen]="sidebarOpen()" (close)="sidebarOpen.set(false)" class="lg:hidden"/>

      <div class="flex-1 flex flex-col overflow-hidden min-w-0">
        <app-header (menuToggle)="sidebarOpen.set(!sidebarOpen())" />

        <main class="flex-1 overflow-y-auto p-4 lg:p-6">
          <div class="max-w-2xl mx-auto">
            <!-- Header -->
            <div class="flex items-center gap-3 mb-6">
              <a
                routerLink="/dashboard/tecnico"
                class="p-2 rounded-lg text-text-secondary hover:bg-white hover:text-accent-green transition-colors"
              >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                </svg>
              </a>
              <div>
                <h1 class="text-2xl font-bold text-text-primary">Buscar Dispositivo</h1>
                <p class="text-sm text-text-secondary">Busca por nombre, ID, ubicación o tipo</p>
              </div>
            </div>

            <!-- Search input -->
            <div class="relative mb-6">
              <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-text-muted" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                </svg>
              </div>
              <input
                [formControl]="searchControl"
                type="search"
                class="w-full bg-white border border-border-color rounded-xl pl-11 pr-4 py-3.5 text-text-primary
                       placeholder-text-muted focus:outline-none focus:ring-2 focus:ring-accent-green focus:border-transparent
                       shadow-sm text-sm"
                placeholder="Buscar por nombre, ID, edificio..."
              />
              @if (searchControl.value) {
                <button
                  (click)="searchControl.setValue('')"
                  class="absolute inset-y-0 right-0 pr-4 flex items-center text-text-muted hover:text-text-secondary"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                  </svg>
                </button>
              }
            </div>

            <!-- Results count -->
            <div class="flex items-center justify-between mb-3">
              <p class="text-sm text-text-muted">
                {{ filteredNodes().length }} dispositivo{{ filteredNodes().length !== 1 ? 's' : '' }}
                @if (searchControl.value) {
                  <span> encontrado{{ filteredNodes().length !== 1 ? 's' : '' }} para "{{ searchControl.value }}"</span>
                }
              </p>
              <!-- Filter chips -->
              <div class="flex gap-2">
                @for (filter of statusFilters; track filter.value) {
                  <button
                    (click)="setStatusFilter(filter.value)"
                    class="px-2.5 py-1 rounded-full text-xs font-medium transition-colors"
                    [ngClass]="activeFilter() === filter.value
                      ? 'bg-accent-green text-white'
                      : 'bg-white text-text-secondary border border-border-color hover:border-accent-green hover:text-accent-green'"
                  >
                    {{ filter.label }}
                  </button>
                }
              </div>
            </div>

            <!-- Device list -->
            <div class="space-y-2">
              @if (loading()) {
                @for (i of [1,2,3,4,5]; track i) {
                  <div class="h-20 bg-white border border-border-color rounded-xl animate-pulse"></div>
                }
              } @else if (filteredNodes().length === 0) {
                <div class="card p-12 flex flex-col items-center text-center">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 text-text-muted mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                  </svg>
                  <p class="text-sm font-medium text-text-primary">No se encontraron dispositivos</p>
                  <p class="text-xs text-text-muted mt-1">Intenta con otro término de búsqueda</p>
                </div>
              } @else {
                @for (node of filteredNodes(); track node.id) {
                  <a
                    [routerLink]="['/devices', node.id]"
                    class="flex items-center gap-4 bg-white border border-border-color rounded-xl px-4 py-3.5
                           hover:border-accent-green hover:shadow-card-hover transition-all cursor-pointer group"
                  >
                    <div
                      class="w-11 h-11 rounded-xl flex items-center justify-center flex-shrink-0"
                      [ngClass]="getNodeBg(node.status)"
                    >
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" [ngClass]="getNodeColor(node.status)" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z"/>
                      </svg>
                    </div>

                    <div class="flex-1 min-w-0">
                      <div class="flex items-center gap-2 flex-wrap">
                        <span class="text-sm font-semibold text-text-primary group-hover:text-accent-green transition-colors">{{ node.name }}</span>
                        <span [ngClass]="getStatusBadge(node.status)">{{ node.status }}</span>
                      </div>
                      <div class="flex items-center gap-2 mt-0.5 flex-wrap">
                        <span class="text-xs text-text-muted font-mono">ID: {{ node.id }}</span>
                        <span class="text-xs text-text-muted">·</span>
                        <span class="text-xs text-text-muted">{{ node.edificio }}</span>
                        <span class="text-xs text-text-muted">·</span>
                        <span class="text-xs text-text-muted capitalize">{{ node.type }}</span>
                      </div>
                    </div>

                    <div class="flex-shrink-0 flex items-center gap-3">
                      <div class="text-right hidden sm:block">
                        <div class="flex items-center gap-1 justify-end">
                          <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" [ngClass]="getBatteryColor(node.battery)" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M15.67 4H14V2h-4v2H8.33C7.6 4 7 4.6 7 5.33v15.33C7 21.4 7.6 22 8.33 22h7.33c.74 0 1.34-.6 1.34-1.33V5.33C17 4.6 16.4 4 15.67 4z"/>
                          </svg>
                          <span class="text-xs font-mono" [ngClass]="getBatteryColor(node.battery)">{{ node.battery }}%</span>
                        </div>
                        <span class="text-xs text-text-muted">{{ node.planta }}</span>
                      </div>
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-text-muted group-hover:text-accent-green transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                      </svg>
                    </div>
                  </a>
                }
              }
            </div>
          </div>
        </main>
      </div>
    </div>
  `,
})
export class DeviceIdSearchComponent implements OnInit {
  private technicalService = inject(TechnicalService);

  sidebarOpen = signal(false);
  loading = signal(false);
  allNodes = signal<IotNode[]>([]);
  filteredNodes = signal<IotNode[]>([]);
  activeFilter = signal('ALL');

  searchControl = new FormControl('');

  statusFilters = [
    { label: 'Todos', value: 'ALL' },
    { label: 'Online', value: 'ONLINE' },
    { label: 'Standby', value: 'STANDBY' },
    { label: 'Offline', value: 'OFFLINE' },
  ];

  ngOnInit(): void {
    this.loadNodes();
    this.searchControl.valueChanges
      .pipe(debounceTime(200), distinctUntilChanged())
      .subscribe(() => this.applyFilters());
  }

  loadNodes(): void {
    this.loading.set(true);
    this.technicalService.getNodes().subscribe({
      next: data => {
        this.allNodes.set(data);
        this.applyFilters();
        this.loading.set(false);
      },
      error: () => {
        this.allNodes.set(this.technicalService.getMockNodes());
        this.applyFilters();
        this.loading.set(false);
      },
    });
  }

  setStatusFilter(value: string): void {
    this.activeFilter.set(value);
    this.applyFilters();
  }

  private applyFilters(): void {
    const query = (this.searchControl.value ?? '').toLowerCase().trim();
    const statusFilter = this.activeFilter();

    let result = this.allNodes();

    if (statusFilter !== 'ALL') {
      result = result.filter(n => n.status === statusFilter);
    }

    if (query) {
      result = result.filter(
        n =>
          n.name.toLowerCase().includes(query) ||
          n.id.toLowerCase().includes(query) ||
          n.edificio.toLowerCase().includes(query) ||
          n.planta.toLowerCase().includes(query) ||
          n.type.toLowerCase().includes(query) ||
          n.location.toLowerCase().includes(query),
      );
    }

    this.filteredNodes.set(result);
  }

  getStatusBadge(status: string): string {
    switch (status) {
      case 'ONLINE': return 'badge-online';
      case 'STANDBY': return 'badge-standby';
      case 'OFFLINE': return 'badge-offline';
      default: return 'badge-standby';
    }
  }

  getNodeBg(status: string): string {
    switch (status) {
      case 'ONLINE': return 'bg-green-50';
      case 'STANDBY': return 'bg-yellow-50';
      case 'OFFLINE': return 'bg-red-50';
      default: return 'bg-surface';
    }
  }

  getNodeColor(status: string): string {
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
