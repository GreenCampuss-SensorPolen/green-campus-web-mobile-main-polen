import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError, timeout } from 'rxjs/operators';
import { APP_CONFIG } from '../../core/config/app-config';
import { TokenStorageService } from './token-storage.service';
import { AIPredictionResponse } from '../models/directivo-data.model';
import {
  HabitabilityStats,
  ZoneConfort,
  PreventiveTask,
} from '../models/facility-management-data.model';

@Injectable({ providedIn: 'root' })
export class FacilityManagementService {
  private http = inject(HttpClient);
  private tokenStorage = inject(TokenStorageService);
  private base = APP_CONFIG.apiBaseUrl;

  private get headers(): HttpHeaders {
    return new HttpHeaders({ Authorization: `Bearer ${this.tokenStorage.getJwt()}` });
  }

  getWeeklyAIPrediction(): Observable<AIPredictionResponse> {
  return this.http.get<AIPredictionResponse>(`${this.base}/predictions/week`, { headers: this.headers });
}

  getHabitability(): Observable<HabitabilityStats> {
    return this.http
      .get<HabitabilityStats>(`${this.base}/management/habitability`, { headers: this.headers })
      .pipe(
        timeout(4000),
        catchError(() => of(this.getMockHabitability())),
      );
  }

  getZones(): Observable<ZoneConfort[]> {
    return this.http
      .get<ZoneConfort[]>(`${this.base}/management/zones`, { headers: this.headers })
      .pipe(
        timeout(4000),
        catchError(() => of(this.getMockZones())),
      );
  }

  getTasks(): Observable<PreventiveTask[]> {
    return this.http
      .get<PreventiveTask[]>(`${this.base}/management/tasks`, { headers: this.headers })
      .pipe(
        timeout(4000),
        catchError(() => of(this.getMockTasks())),
      );
  }

  // Mock data for development
  getMockHabitability(): HabitabilityStats {
    return { averageTemp: 22.3, averageHumidity: 58.4, averageCo2: 425 };
  }

  getMockZones(): ZoneConfort[] {
    return [
      { id: 'z1', name: 'Aula 101', status: 'OPTIMO', temp: 21.5, humidity: 55 },
      { id: 'z2', name: 'Aula 102', status: 'OPTIMO', temp: 22.1, humidity: 60 },
      { id: 'z3', name: 'Lab Física', status: 'REGULAR', temp: 25.8, humidity: 68 },
      { id: 'z4', name: 'Biblioteca', status: 'OPTIMO', temp: 20.9, humidity: 52 },
      { id: 'z5', name: 'Cafetería', status: 'CRITICO', temp: 28.4, humidity: 75 },
      { id: 'z6', name: 'Gimnasio', status: 'REGULAR', temp: 26.2, humidity: 70 },
    ];
  }

  getMockTasks(): PreventiveTask[] {
    return [
      {
        id: 't1',
        title: 'Revisión filtros HVAC',
        location: 'Edificio A - Planta 1',
        daysRemaining: 3,
        priority: 'CRITICAL',
      },
      {
        id: 't2',
        title: 'Calibración sensores CO2',
        location: 'Laboratorio Física',
        daysRemaining: 7,
        priority: 'MEDIUM',
      },
      {
        id: 't3',
        title: 'Limpieza paneles solares',
        location: 'Azotea Edificio B',
        daysRemaining: 15,
        priority: 'LOW',
      },
      {
        id: 't4',
        title: 'Inspección sistema eléctrico',
        location: 'Sala Servidores',
        daysRemaining: 2,
        priority: 'CRITICAL',
      },
      {
        id: 't5',
        title: 'Revisión extintores',
        location: 'Todos los pisos',
        daysRemaining: 21,
        priority: 'MEDIUM',
      },
    ];
  }
}
