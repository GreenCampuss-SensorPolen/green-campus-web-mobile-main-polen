import { Component, inject, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { TokenStorageService } from '../../../data/services/token-storage.service';
import { AuthService } from '../../../data/services/auth.service';
import { ROLE_LABELS } from '../../../core/constants/user-roles';

interface NavItem {
  label: string;
  icon: string;
  route: string;
  roles?: string[];
}

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [CommonModule, RouterLink, RouterLinkActive],
  template: `
    <!-- Backdrop (mobile) -->
    @if (isOpen) {
      <div
        class="fixed inset-0 bg-black/40 z-40 lg:hidden"
        (click)="close.emit()"
      ></div>
    }

    <!-- Sidebar panel -->
    <aside
      class="fixed top-0 left-0 h-full bg-white border-r border-border-color z-50 flex flex-col
             transition-transform duration-300 ease-in-out
             w-64 lg:translate-x-0 lg:static lg:z-auto"
      [class.translate-x-0]="isOpen"
      [class.-translate-x-full]="!isOpen"
    >
      <!-- Logo area -->
      <div class="h-16 flex items-center gap-3 px-5 border-b border-border-color">
        <div class="w-8 h-8 bg-accent-green rounded-lg flex items-center justify-center flex-shrink-0">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-white" viewBox="0 0 24 24" fill="currentColor">
            <path d="M17 8C8 10 5.9 16.17 3.82 21c2.83-2.07 5.57-3.53 8.18-4.07C13.17 15.83 15.5 13 17 8z"/>
            <path d="M17 8c0 8-7 13-14 13 0-7 5-13 14-13z" opacity="0.5"/>
          </svg>
        </div>
        <div>
          <p class="font-semibold text-text-primary text-sm leading-tight">Green Campus</p>
          <p class="text-xs text-text-muted">{{ roleLabel }}</p>
        </div>
        <!-- Close on mobile -->
        <button
          class="ml-auto p-1.5 rounded-lg text-text-muted hover:bg-surface lg:hidden"
          (click)="close.emit()"
          aria-label="Close sidebar"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
          </svg>
        </button>
      </div>

      <!-- User info -->
      <div class="px-4 py-4 border-b border-border-color">
        <div class="flex items-center gap-3">
          @if (user?.profileImageUrl) {
            <img [src]="user?.profileImageUrl" alt="Avatar" class="w-10 h-10 rounded-full object-cover"/>
          } @else {
            <div class="w-10 h-10 rounded-full bg-accent-green-light border border-accent-green flex items-center justify-center flex-shrink-0">
              <span class="text-accent-green font-bold text-sm">{{ initials }}</span>
            </div>
          }
          <div class="min-w-0">
            <p class="text-sm font-semibold text-text-primary truncate">{{ user?.firstName }} {{ user?.lastName }}</p>
            <p class="text-xs text-text-muted truncate">{{ user?.email }}</p>
          </div>
        </div>
      </div>

      <!-- Navigation -->
      <nav class="flex-1 overflow-y-auto px-3 py-4 space-y-1">
        @for (item of visibleNavItems; track item.route) {
          <a
            [routerLink]="item.route"
            routerLinkActive="bg-accent-green-bg !text-accent-green font-medium"
            (click)="close.emit()"
            class="sidebar-link"
          >
            <span class="w-5 h-5 flex-shrink-0" [innerHTML]="item.icon"></span>
            <span class="text-sm">{{ item.label }}</span>
          </a>
        }
      </nav>

      <!-- Bottom actions -->
      <div class="px-3 py-4 border-t border-border-color space-y-1">
        <a
          routerLink="/profile"
          routerLinkActive="bg-accent-green-bg !text-accent-green"
          (click)="close.emit()"
          class="sidebar-link"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
          </svg>
          <span class="text-sm">Mi Perfil</span>
        </a>
        <button
          (click)="onLogout()"
          class="sidebar-link w-full text-left text-red-500 hover:bg-red-50 hover:text-red-600"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
          </svg>
          <span class="text-sm">Cerrar sesión</span>
        </button>
      </div>
    </aside>
  `,
})
export class AppSidebarComponent {
  @Input() isOpen = false;
  @Output() close = new EventEmitter<void>();

  private tokenStorage = inject(TokenStorageService);
  private authService = inject(AuthService);
  private router = inject(Router);

  private readonly navItems: NavItem[] = [
    {
      label: 'Dashboard',
      route: '/dashboard/servicios',
      roles: ['SERVICIOS_GENERALES'],
      icon: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg>`,
    },
    {
      label: 'Dashboard',
      route: '/dashboard/tecnico',
      roles: ['TECNICO'],
      icon: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 3H5a2 2 0 00-2 2v4m6-6h10a2 2 0 012 2v4M9 3v18m0 0h10a2 2 0 002-2v-4M9 21H5a2 2 0 01-2-2v-4m0 0h18"/></svg>`,
    },
    {
      label: 'Dashboard',
      route: '/dashboard/directivo',
      roles: ['DIRECTIVO'],
      icon: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M16 8v8m-4-5v5m-4-2v2m-2 4h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>`,
    },
    {
      label: 'Dispositivos',
      route: '/devices',
      roles: ['TECNICO'],
      icon: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z"/></svg>`,
    },
    {
      label: 'Notificaciones',
      route: '/notifications',
      icon: `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></svg>`,
    },
  ];

  get user() {
    return this.tokenStorage.currentUser;
  }

  get roleLabel(): string {
    return ROLE_LABELS[this.user?.role ?? ''] ?? '';
  }

  get initials(): string {
    const u = this.user;
    if (!u) return '?';
    return `${u.firstName?.charAt(0) ?? ''}${u.lastName?.charAt(0) ?? ''}`.toUpperCase();
  }

  get visibleNavItems(): NavItem[] {
    const role = this.user?.role;
    return this.navItems.filter(item => !item.roles || item.roles.includes(role ?? ''));
  }

  onLogout(): void {
    this.authService.logoutLocal();
    this.router.navigate(['/login']);
  }
}
