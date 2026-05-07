import { Component, Input, OnChanges, SimpleChanges } from '@angular/core';
import { CommonModule } from '@angular/common';

export type GaugeType = 'temperatura' | 'humedad' | 'calidadAire' | 'energia';

interface GaugeConfig {
  min: number;
  max: number;
  unit: string;
  label: string;
  zones: { from: number; to: number; color: string; label: string }[];
}

const GAUGE_CONFIGS: Record<GaugeType, GaugeConfig> = {
  temperatura: {
    min: 0, max: 50, unit: '°C', label: 'Temperatura',
    zones: [
      { from: 0, to: 18, color: '#3B82F6', label: 'Frío' },
      { from: 18, to: 26, color: '#22C55E', label: 'Óptimo' },
      { from: 26, to: 35, color: '#F59E0B', label: 'Caliente' },
      { from: 35, to: 50, color: '#EF4444', label: 'Crítico' },
    ],
  },
  humedad: {
    min: 0, max: 100, unit: '%', label: 'Humedad',
    zones: [
      { from: 0, to: 30, color: '#F59E0B', label: 'Seco' },
      { from: 30, to: 60, color: '#22C55E', label: 'Óptimo' },
      { from: 60, to: 80, color: '#F59E0B', label: 'Húmedo' },
      { from: 80, to: 100, color: '#EF4444', label: 'Crítico' },
    ],
  },
  calidadAire: {
    min: 0, max: 2000, unit: 'ppm', label: 'CO₂',
    zones: [
      { from: 0, to: 600, color: '#22C55E', label: 'Excelente' },
      { from: 600, to: 1000, color: '#84CC16', label: 'Bueno' },
      { from: 1000, to: 1500, color: '#F59E0B', label: 'Moderado' },
      { from: 1500, to: 2000, color: '#EF4444', label: 'Crítico' },
    ],
  },
  energia: {
    min: 0, max: 20, unit: 'kWh', label: 'Energía',
    zones: [
      { from: 0, to: 5, color: '#22C55E', label: 'Bajo' },
      { from: 5, to: 12, color: '#F59E0B', label: 'Moderado' },
      { from: 12, to: 20, color: '#EF4444', label: 'Alto' },
    ],
  },
};

@Component({
  selector: 'app-sensor-gauge',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="flex flex-col items-center">
      <svg [attr.viewBox]="'0 0 200 130'" class="w-full max-w-xs" xmlns="http://www.w3.org/2000/svg">
        <!-- Background arc segments (colored zones) -->
        @for (zone of config.zones; track zone.label) {
          <path
            [attr.d]="getZoneArcPath(zone.from, zone.to)"
            [attr.stroke]="zone.color"
            stroke-width="14"
            fill="none"
            stroke-linecap="butt"
            opacity="0.25"
          />
        }

        <!-- Active arc (filled up to current value) -->
        <path
          [attr.d]="getValueArcPath()"
          [attr.stroke]="currentZoneColor"
          stroke-width="14"
          fill="none"
          stroke-linecap="round"
          class="transition-all duration-700 ease-out"
        />

        <!-- Center circle -->
        <circle cx="100" cy="100" r="52" fill="white" />
        <circle cx="100" cy="100" r="50" fill="white" stroke="#E2E8F0" stroke-width="1.5" />

        <!-- Value text -->
        <text x="100" y="95" text-anchor="middle" dominant-baseline="middle"
          font-family="'JetBrains Mono', monospace" font-size="26" font-weight="600"
          [attr.fill]="currentZoneColor">
          {{ displayValue }}
        </text>
        <text x="100" y="114" text-anchor="middle" dominant-baseline="middle"
          font-family="Inter, sans-serif" font-size="11" fill="#64748B">
          {{ config.unit }}
        </text>

        <!-- Min / Max labels -->
        <text x="15" y="115" text-anchor="middle" font-family="Inter, sans-serif" font-size="9" fill="#94A3B8">
          {{ config.min }}
        </text>
        <text x="185" y="115" text-anchor="middle" font-family="Inter, sans-serif" font-size="9" fill="#94A3B8">
          {{ config.max }}
        </text>

        <!-- Needle -->
        <line
          [attr.x1]="100"
          [attr.y1]="100"
          [attr.x2]="needleX"
          [attr.y2]="needleY"
          [attr.stroke]="currentZoneColor"
          stroke-width="2.5"
          stroke-linecap="round"
          class="transition-all duration-700 ease-out"
        />
        <circle cx="100" cy="100" r="4" [attr.fill]="currentZoneColor" />
      </svg>

      <!-- Zone status label -->
      <div
        class="mt-1 px-3 py-1 rounded-full text-xs font-medium"
        [style.background-color]="currentZoneColor + '20'"
        [style.color]="currentZoneColor"
      >
        {{ currentZoneLabel }}
      </div>

      <!-- Zone legend -->
      <div class="flex flex-wrap justify-center gap-2 mt-3">
        @for (zone of config.zones; track zone.label) {
          <div class="flex items-center gap-1">
            <div class="w-3 h-3 rounded-full" [style.background-color]="zone.color"></div>
            <span class="text-xs text-text-muted">{{ zone.label }}</span>
          </div>
        }
      </div>
    </div>
  `,
})
export class SensorGaugeComponent implements OnChanges {
  @Input() type: GaugeType = 'temperatura';
  @Input() value = 0;

  config: GaugeConfig = GAUGE_CONFIGS['temperatura'];
  displayValue = '0';
  needleX = 100;
  needleY = 48;
  currentZoneColor = '#22C55E';
  currentZoneLabel = 'Óptimo';

  private readonly cx = 100;
  private readonly cy = 100;
  private readonly r = 75;
  private readonly startAngle = 225; // degrees
  private readonly endAngle = 315;   // degrees (225 + 270)
  private readonly totalAngle = 270;

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['type']) {
      this.config = GAUGE_CONFIGS[this.type] ?? GAUGE_CONFIGS['temperatura'];
    }
    this.updateGauge();
  }

  private updateGauge(): void {
    const clampedValue = Math.max(this.config.min, Math.min(this.config.max, this.value));
    const pct = (clampedValue - this.config.min) / (this.config.max - this.config.min);
    const angle = this.startAngle + pct * this.totalAngle;
    const rad = (angle * Math.PI) / 180;
    const needleR = 42;
    this.needleX = this.cx + needleR * Math.cos(rad);
    this.needleY = this.cy + needleR * Math.sin(rad);
    this.displayValue = Number.isInteger(this.value) ? this.value.toString() : this.value.toFixed(1);

    const zone = this.config.zones.find(z => clampedValue >= z.from && clampedValue < z.to)
      ?? this.config.zones[this.config.zones.length - 1];
    this.currentZoneColor = zone.color;
    this.currentZoneLabel = zone.label;
  }

  getZoneArcPath(from: number, to: number): string {
    const range = this.config.max - this.config.min;
    const startPct = (from - this.config.min) / range;
    const endPct = (to - this.config.min) / range;
    const startAngle = this.startAngle + startPct * this.totalAngle;
    const endAngle = this.startAngle + endPct * this.totalAngle;
    return this.arcPath(startAngle, endAngle);
  }

  getValueArcPath(): string {
    const clampedValue = Math.max(this.config.min, Math.min(this.config.max, this.value));
    const pct = (clampedValue - this.config.min) / (this.config.max - this.config.min);
    const endAngle = this.startAngle + pct * this.totalAngle;
    if (pct <= 0) return '';
    return this.arcPath(this.startAngle, endAngle);
  }

  private arcPath(startDeg: number, endDeg: number): string {
    const toRad = (d: number) => (d * Math.PI) / 180;
    const sx = this.cx + this.r * Math.cos(toRad(startDeg));
    const sy = this.cy + this.r * Math.sin(toRad(startDeg));
    const ex = this.cx + this.r * Math.cos(toRad(endDeg));
    const ey = this.cy + this.r * Math.sin(toRad(endDeg));
    const diff = endDeg - startDeg;
    const largeArc = diff > 180 ? 1 : 0;
    return `M ${sx} ${sy} A ${this.r} ${this.r} 0 ${largeArc} 1 ${ex} ${ey}`;
  }
}
