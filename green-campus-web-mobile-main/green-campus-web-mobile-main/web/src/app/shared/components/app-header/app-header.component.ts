import { Component, inject, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink } from '@angular/router';
import { TokenStorageService } from '../../../data/services/token-storage.service';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [CommonModule, RouterLink],
  template: `
    <header class="bg-white border-b border-border-color h-16 flex items-center justify-between px-4 lg:px-6 sticky top-0 z-40 shadow-sm">
      <!-- Left: hamburger + logo -->
      <div class="flex items-center gap-3">
        @if (showMenuButton) {
          <button
            (click)="menuToggle.emit()"
            class="p-2 rounded-lg text-text-secondary hover:bg-surface hover:text-accent-green transition-colors lg:hidden"
            aria-label="Toggle menu"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
            </svg>
          </button>
        }
        <div class="flex items-center gap-2">
          <!-- Green campus leaf logo -->
          <div class="w-8 h-8 bg-accent-green rounded-lg flex items-center justify-center">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-white" viewBox="0 0 24 24" fill="currentColor">
              <path d="M17 8C8 10 5.9 16.17 3.82 21c2.83-2.07 5.57-3.53 8.18-4.07C13.17 15.83 15.5 13 17 8z"/>
              <path d="M17 8c0 8-7 13-14 13 0-7 5-13 14-13z" opacity="0.5"/>
            </svg>
          </div>
          <span class="font-semibold text-text-primary text-lg hidden sm:block">Green Campus</span>
        </div>
      </div>

      <!-- Right: notifications + avatar -->
      <div class="flex items-center gap-2">
        <button
          routerLink="/notifications"
          class="relative p-2 rounded-lg text-text-secondary hover:bg-surface hover:text-accent-green transition-colors"
          aria-label="Notifications"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
          </svg>
        </button>

        <button
          routerLink="/profile"
          class="flex items-center gap-2 p-1 rounded-lg hover:bg-surface transition-colors"
          aria-label="Profile"
        >
          @if (user?.profileImageUrl) {
            <img [src]="user?.profileImageUrl" alt="Avatar" class="w-8 h-8 rounded-full object-cover border border-border-color"/>
          } @else {
            <div class="w-8 h-8 rounded-full bg-accent-green-light border border-accent-green flex items-center justify-center">
              <span class="text-accent-green font-semibold text-sm">{{ initials }}</span>
            </div>
          }
        </button>
      </div>
    </header>
  `,
})
export class AppHeaderComponent {
  @Input() showMenuButton = true;
  @Output() menuToggle = new EventEmitter<void>();

  private tokenStorage = inject(TokenStorageService);

  get user() {
    return this.tokenStorage.currentUser;
  }

  get initials(): string {
    const u = this.user;
    if (!u) return '?';
    return `${u.firstName?.charAt(0) ?? ''}${u.lastName?.charAt(0) ?? ''}`.toUpperCase();
  }
}
