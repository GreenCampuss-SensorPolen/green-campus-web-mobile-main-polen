import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { APP_CONFIG } from '../../core/config/app-config';
import { TokenStorageService } from './token-storage.service';
import {
  LoginRequest,
  LoginResponse,
  ForgotPasswordRequest,
  ResetPasswordRequest,
} from '../models/login-response.model';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private http = inject(HttpClient);
  private tokenStorage = inject(TokenStorageService);
  private base = APP_CONFIG.apiBaseUrl;

  login(credentials: LoginRequest): Observable<LoginResponse> {
    return this.http.post<LoginResponse>(`${this.base}/auth/login`, credentials).pipe(
      tap(res => {
        this.tokenStorage.save({
          jwt: res.jwt,
          email: res.email,
          role: res.role,
          profileImageUrl: res.profileImageUrl,
          firstName: res.firstName,
          lastName: res.lastName,
        });
      }),
    );
  }

  forgotPassword(req: ForgotPasswordRequest): Observable<{ message: string }> {
    return this.http.post<{ message: string }>(`${this.base}/auth/forgot-password`, req);
  }

  resetPassword(req: ResetPasswordRequest): Observable<{ message: string }> {
    return this.http.post<{ message: string }>(`${this.base}/auth/reset-password`, req);
  }

  logout(): Observable<{ message: string }> {
    const jwt = this.tokenStorage.getJwt();
    return this.http
      .post<{ message: string }>(
        `${this.base}/auth/logout`,
        {},
        { headers: { Authorization: `Bearer ${jwt}` } },
      )
      .pipe(tap(() => this.tokenStorage.clear()));
  }

  logoutLocal(): void {
    this.tokenStorage.clear();
  }
}
