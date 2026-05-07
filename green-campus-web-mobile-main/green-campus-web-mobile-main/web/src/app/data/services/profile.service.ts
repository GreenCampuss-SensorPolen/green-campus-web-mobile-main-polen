import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { APP_CONFIG } from '../../core/config/app-config';
import { TokenStorageService } from './token-storage.service';

export interface UpdateProfileRequest {
  firstName?: string;
  lastName?: string;
  password?: string;
}

@Injectable({ providedIn: 'root' })
export class ProfileService {
  private http = inject(HttpClient);
  private tokenStorage = inject(TokenStorageService);
  private base = APP_CONFIG.apiBaseUrl;

  private get headers(): HttpHeaders {
    return new HttpHeaders({ Authorization: `Bearer ${this.tokenStorage.getJwt()}` });
  }

  updateProfile(data: UpdateProfileRequest): Observable<void> {
    return this.http
      .patch<void>(`${this.base}/user/profile`, data, { headers: this.headers })
      .pipe(
        tap(() => {
          if (data.firstName !== undefined && data.lastName !== undefined) {
            this.tokenStorage.updateProfile(data.firstName, data.lastName);
          }
        }),
      );
  }
}
