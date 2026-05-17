import { Component, signal, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AppHeaderComponent } from '../../../shared/components/app-header/app-header.component';
import { AppSidebarComponent } from '../../../shared/components/app-sidebar/app-sidebar.component';
import { FacilityManagementService } from '../../../data/services/facility-management.service';
import { DailyPrediction } from '../../../data/models/directivo-data.model';

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

        <main class="flex-1 overflow-y-auto p-8">
          
          <div class="mb-8 flex justify-between items-center">
            <div>
              <h1 class="text-3xl font-bold text-text-primary mb-2">Panel Directivo: Calidad del Aire AI</h1>
              <p class="text-text-secondary">Predicción inteligente multivariable (Próximos 7 días)</p>
            </div>
          </div>

          @if (prediccionesSemanales().length === 0) {
            <div class="flex justify-center items-center h-64">
              <div class="animate-pulse flex flex-col items-center">
                <div class="w-12 h-12 border-4 border-accent-green border-t-transparent rounded-full animate-spin mb-4"></div>
                <p class="text-text-muted">La IA está calculando el pronóstico...</p>
              </div>
            </div>
          } @else {
            <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6 mb-8">
              @for (dia of prediccionesSemanales(); track dia.target_date) {
                
                <div (click)="seleccionarDia(dia)" 
                     class="card p-6 bg-white rounded-xl shadow-sm border transition-all duration-200 cursor-pointer hover:shadow-md hover:border-accent-green group"
                     [ngClass]="{'border-accent-green ring-2 ring-accent-green-light': diaSeleccionado()?.target_date === dia.target_date, 'border-gray-100': diaSeleccionado()?.target_date !== dia.target_date}">
                  
                  <div class="flex justify-between items-start mb-4">
                    <div>
                      <p class="text-sm font-semibold text-text-muted uppercase tracking-wider group-hover:text-accent-green transition-colors">{{ dia.target_date | date:'mediumDate' }}</p>
                      <p class="text-xs mt-1 px-2 py-1 bg-gray-100 rounded-md inline-block font-medium" 
                         [ngClass]="{'bg-green-100 text-green-700': dia.day_type === 'Fin de semana', 'bg-blue-100 text-blue-700': dia.day_type !== 'Fin de semana'}">
                        {{ dia.day_type }}
                      </p>
                    </div>
                    <div class="w-10 h-10 rounded-full flex items-center justify-center transition-colors"
                         [ngClass]="dia.daily_average > 800 ? 'bg-red-100 text-red-500' : 'bg-green-100 text-green-500'">
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z" />
                      </svg>
                    </div>
                  </div>
                  
                  <div class="flex flex-col gap-3">
                    <div>
                      <span class="text-xs text-text-muted block">CO₂ Promedio</span>
                      <p class="text-3xl font-bold text-text-primary">
                        {{ dia.daily_average }} <span class="text-sm font-normal text-text-muted">ppm</span>
                      </p>
                    </div>
                    <div class="flex items-center gap-1.5 text-orange-500">
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                      </svg>
                      <span class="font-bold text-lg">{{ dia.temperature_average }} °C</span>
                    </div>
                  </div>
                  
                  <div class="mt-4 pt-3 border-t border-gray-50 flex justify-between items-center">
                    <p class="text-xs font-semibold uppercase tracking-wider" [ngClass]="dia.daily_average > 800 ? 'text-red-600' : 'text-green-600'">
                      {{ dia.daily_average > 800 ? '⚠️ Ventilar' : '✅ Óptimo' }}
                    </p>
                    <span class="text-xs text-text-muted group-hover:text-accent-green font-medium flex items-center gap-0.5">
                      Detalle horaria →
                    </span>
                  </div>
                </div>

              }
            </div>

            @if (diaSeleccionado(); as seleccionado) {
              <div class="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm animate-fadeIn">
                <div class="flex justify-between items-center border-b border-gray-100 pb-4 mb-6">
                  <div>
                    <h2 class="text-xl font-bold text-text-primary">Curva Horaria de Predicción</h2>
                    <p class="text-sm text-text-secondary">Evolución estimada para el {{ seleccionado.target_date | date:'longDate' }}</p>
                  </div>
                  <button (click)="cerrarDetalle()" class="px-3 py-1.5 text-xs font-semibold text-gray-500 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors">
                    Cerrar detalle ×
                  </button>
                </div>

                <div class="flex gap-4 overflow-x-auto pb-4 pt-2 scrollbar-thin">
                  @for (pred of seleccionado.hourly_predictions; track pred.hour) {
                    
                    <div class="flex flex-col items-center min-w-[85px] p-4 rounded-xl border border-gray-50 bg-slate-50/50 hover:bg-slate-50 transition-colors">
                      <span class="text-xs font-bold text-text-muted mb-2">{{ pred.hour }}</span>
                      
                      <div class="w-8 h-8 rounded-full flex items-center justify-center mb-3"
                           [ngClass]="pred.co2 > 800 ? 'bg-red-50 text-red-500' : 'bg-green-50 text-green-500'">
                        <i class="fa-solid fa-wind text-xs"></i>
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364-6.364l-.707.707M6.343 17.657l-.707.707m12.728 0l-.707-.707M6.343 6.343l-.707-.707M14 12a2 2 0 11-4 0 2 2 0 014 0z" />
                        </svg>
                      </div>

                      <div class="text-center">
                        <span class="text-sm font-extrabold text-text-primary block">{{ pred.co2 }}</span>
                        <span class="text-[10px] text-text-muted uppercase font-semibold block mb-2">ppm</span>
                        
                        <span class="text-xs font-bold text-orange-600 bg-orange-50 px-1.5 py-0.5 rounded-md">{{ pred.temperature }}°C</span>
                      </div>
                    </div>

                  }
                </div>
              </div>
            }
          }
        </main>
      </div>
    </div>
  `,
  styles: [`
    .scrollbar-thin::-webkit-scrollbar { height: 6px; }
    .scrollbar-thin::-webkit-scrollbar-track { background: #f1f5f9; border-radius: 10px; }
    .scrollbar-thin::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
    .scrollbar-thin::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
  `]
})
export class DirectivoDashboardComponent implements OnInit {
  sidebarOpen = signal(false);
  private facilityService = inject(FacilityManagementService);

  prediccionesSemanales = signal<DailyPrediction[]>([]);
  
  // Nuevo signal para controlar qué día se despliega por horas
  diaSeleccionado = signal<DailyPrediction | null>(null);

  ngOnInit(): void {
    this.facilityService.getWeeklyAIPrediction().subscribe({
      next: (datosIA) => {
        if (datosIA.week_predictions) {
          this.prediccionesSemanales.set(datosIA.week_predictions);
          
          // Por defecto, dejamos seleccionado el primer día para que no aparezca vacío
          this.diaSeleccionado.set(datosIA.week_predictions[0]);
        }
      },
      error: (err) => console.error('Error al llamar a la IA', err)
    });
  }

  seleccionarDia(dia: DailyPrediction): void {
    this.diaSeleccionado.set(dia);
  }

  cerrarDetalle(): void {
    this.diaSeleccionado.set(null);
  }
}