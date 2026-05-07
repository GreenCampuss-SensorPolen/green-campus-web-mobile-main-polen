import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

const KEYS = {
  JWT: 'gc_jwt',
  EMAIL: 'gc_email',
  ROLE: 'gc_role',
  PROFILE_IMAGE: 'gc_profile_image',
  FIRST_NAME: 'gc_first_name',
  LAST_NAME: 'gc_last_name',
} as const;

export interface StoredUser {
  jwt: string;
  email: string;
  role: string;
  profileImageUrl: string;
  firstName: string;
  lastName: string;
}

@Injectable({ providedIn: 'root' })
export class TokenStorageService {
  private _user$ = new BehaviorSubject<StoredUser | null>(this.loadUser());

  get user$() {
    return this._user$.asObservable();
  }

  get currentUser(): StoredUser | null {
    return this._user$.value;
  }

  save(user: StoredUser): void {
    localStorage.setItem(KEYS.JWT, user.jwt);
    localStorage.setItem(KEYS.EMAIL, user.email);
    localStorage.setItem(KEYS.ROLE, user.role);
    localStorage.setItem(KEYS.PROFILE_IMAGE, user.profileImageUrl ?? '');
    localStorage.setItem(KEYS.FIRST_NAME, user.firstName);
    localStorage.setItem(KEYS.LAST_NAME, user.lastName);
    this._user$.next(user);
  }

  updateProfile(firstName: string, lastName: string): void {
    localStorage.setItem(KEYS.FIRST_NAME, firstName);
    localStorage.setItem(KEYS.LAST_NAME, lastName);
    const current = this._user$.value;
    if (current) {
      this._user$.next({ ...current, firstName, lastName });
    }
  }

  clear(): void {
    Object.values(KEYS).forEach(key => localStorage.removeItem(key));
    this._user$.next(null);
  }

  getJwt(): string | null {
    return localStorage.getItem(KEYS.JWT);
  }

  isLoggedIn(): boolean {
    return !!this.getJwt();
  }

  private loadUser(): StoredUser | null {
    const jwt = localStorage.getItem(KEYS.JWT);
    if (!jwt) return null;
    return {
      jwt,
      email: localStorage.getItem(KEYS.EMAIL) ?? '',
      role: localStorage.getItem(KEYS.ROLE) ?? '',
      profileImageUrl: localStorage.getItem(KEYS.PROFILE_IMAGE) ?? '',
      firstName: localStorage.getItem(KEYS.FIRST_NAME) ?? '',
      lastName: localStorage.getItem(KEYS.LAST_NAME) ?? '',
    };
  }
}
