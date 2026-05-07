import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError, timeout } from 'rxjs/operators';
import { APP_CONFIG } from '../../core/config/app-config';
import { TokenStorageService } from './token-storage.service';
import { IotNode, MonthlyReading } from '../models/technical-data.model';

@Injectable({ providedIn: 'root' })
export class TechnicalService {
  private http = inject(HttpClient);
  private tokenStorage = inject(TokenStorageService);
  private base = APP_CONFIG.apiBaseUrl;

  private get headers(): HttpHeaders {
    return new HttpHeaders({ Authorization: `Bearer ${this.tokenStorage.getJwt()}` });
  }

  getNodes(): Observable<IotNode[]> {
    return this.http
      .get<IotNode[]>(`${this.base}/technical/nodes`, { headers: this.headers })
      .pipe(
        timeout(4000),
        catchError(() => of(this.getMockNodes())),
      );
  }

  getNodeById(id: string): Observable<IotNode> {
    const mock = this.getMockNodes().find(n => n.id === id);
    return this.http
      .get<IotNode>(`${this.base}/technical/nodes/${id}`, { headers: this.headers })
      .pipe(
        timeout(4000),
        catchError(() => of(mock ?? this.getMockNodes()[0])),
      );
  }

  getMonthlyReadings(
    type: string,
    year: number,
    month: number,
  ): Observable<MonthlyReading[]> {
    return this.http
      .get<MonthlyReading[]>(
        `${this.base}/technical/nodes/${type}/readings/monthly`,
        {
          headers: this.headers,
          params: { year: year.toString(), month: month.toString() },
        },
      )
      .pipe(
        timeout(4000),
        catchError(() => of(this.getMockMonthlyReadings(type))),
      );
  }

  getMockMonthlyReadings(type: string): MonthlyReading[] {
    const base: Record<string, number[]> = {
      TEMPERATURA: [21.2, 21.8, 22.5, 22.1, 23.0, 22.7, 21.9, 22.3, 23.1, 22.8,
                    21.5, 22.0, 23.4, 22.9, 21.7, 22.4, 23.2, 22.6, 21.8, 22.1,
                    22.9, 23.0, 22.5, 21.9, 22.6, 23.1, 22.3, 21.8, 22.7, 23.0, 22.4],
      HUMEDAD:    [55.1, 56.2, 58.0, 57.4, 59.1, 58.5, 56.8, 57.9, 60.2, 59.4,
                   56.5, 57.2, 61.0, 60.1, 56.9, 58.3, 61.5, 59.8, 57.1, 58.0,
                   60.5, 61.2, 59.1, 57.4, 58.8, 61.9, 59.3, 57.8, 60.3, 61.0, 58.9],
      CO2:        [410, 418, 425, 420, 432, 428, 415, 422, 438, 430,
                   417, 421, 442, 435, 419, 426, 445, 433, 416, 423,
                   436, 440, 428, 418, 431, 443, 425, 420, 437, 440, 426],
    };
    const typeKey = type.toUpperCase();
    const values = base[typeKey] ?? base['TEMPERATURA'];
    return values.map((value, i) => ({
      day: String(i + 1),
      value: value.toFixed(2),
    }));
  }

  // Mock data for development when API is unavailable
  getMockNodes(): IotNode[] {
    return [
      {
        id: 'node-001',
        name: 'Sensor Aula 101',
        location: 'Aula 101',
        type: 'temperatura',
        status: 'ONLINE',
        battery: 87,
        edificio: 'Edificio A',
        planta: 'Planta 1',
        rssi: -65,
        uptime: 1440,
        linkQuality: 92,
        lastTelemetry: { temperature: 22.4, humidity: 58, co2: 420 },
      },
      {
        id: 'node-002',
        name: 'Sensor Lab Física',
        location: 'Laboratorio Física',
        type: 'humedad',
        status: 'ONLINE',
        battery: 63,
        edificio: 'Edificio B',
        planta: 'Planta 2',
        rssi: -72,
        uptime: 720,
        linkQuality: 85,
        lastTelemetry: { temperature: 24.1, humidity: 65, co2: 510 },
      },
      {
        id: 'node-003',
        name: 'Sensor Biblioteca',
        location: 'Biblioteca Principal',
        type: 'calidadAire',
        status: 'STANDBY',
        battery: 45,
        edificio: 'Edificio C',
        planta: 'Planta 1',
        rssi: -80,
        uptime: 360,
        linkQuality: 70,
        lastTelemetry: { temperature: 20.8, humidity: 52, co2: 380 },
      },
      {
        id: 'node-004',
        name: 'Raspberry Pi Principal',
        location: 'Sala Servidores',
        type: 'Raspberry Pi',
        status: 'ONLINE',
        battery: 100,
        edificio: 'Edificio A',
        planta: 'Sótano',
        rssi: -45,
        uptime: 7200,
        linkQuality: 99,
        lastTelemetry: { energy: 4.2 },
      },
      {
        id: 'node-005',
        name: 'Sensor Cafetería',
        location: 'Cafetería',
        type: 'temperatura',
        status: 'OFFLINE',
        battery: 12,
        edificio: 'Edificio D',
        planta: 'Planta 0',
        rssi: -95,
        uptime: 0,
        linkQuality: 20,
        lastTelemetry: { temperature: 0, humidity: 0 },
      },
      {
        id: 'node-006',
        name: 'Arduino Gimnasio',
        location: 'Gimnasio',
        type: 'Arduino',
        status: 'ONLINE',
        battery: 78,
        edificio: 'Edificio E',
        planta: 'Planta 1',
        rssi: -60,
        uptime: 2160,
        linkQuality: 88,
        lastTelemetry: { temperature: 26.5, humidity: 72, co2: 650 },
      },
    ];
  }
}
