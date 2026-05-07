import { Routes } from '@angular/router';
import { authGuard } from './guards/auth.guard';
import { roleGuard } from './guards/role.guard';

export const routes: Routes = [
  // Root redirect
  {
    path: '',
    redirectTo: 'login',
    pathMatch: 'full',
  },

  // Auth routes (public)
  {
    path: 'login',
    loadComponent: () =>
      import('./pages/login/login.component').then(m => m.LoginComponent),
    title: 'Green Campus — Iniciar sesión',
  },
  {
    path: 'forgot-password',
    loadComponent: () =>
      import('./pages/forgot-password/request-reset/request-reset.component').then(
        m => m.RequestResetComponent,
      ),
    title: 'Green Campus — Recuperar contraseña',
  },
  {
    path: 'new-password',
    loadComponent: () =>
      import('./pages/forgot-password/new-password/new-password.component').then(
        m => m.NewPasswordComponent,
      ),
    title: 'Green Campus — Nueva contraseña',
  },

  // Protected routes
  {
    path: 'dashboard',
    canActivate: [authGuard],
    children: [
      {
        path: 'servicios',
        canActivate: [roleGuard],
        data: { roles: ['SERVICIOS_GENERALES'] },
        loadComponent: () =>
          import('./pages/dashboard/facility-management/facility-management.component').then(
            m => m.FacilityManagementComponent,
          ),
        title: 'Green Campus — Gestión de Instalaciones',
      },
      {
        path: 'tecnico',
        canActivate: [roleGuard],
        data: { roles: ['TECNICO'] },
        loadComponent: () =>
          import('./pages/dashboard/technical/technical-dashboard.component').then(
            m => m.TechnicalDashboardComponent,
          ),
        title: 'Green Campus — Panel Técnico',
      },
      {
        path: 'directivo',
        canActivate: [roleGuard],
        data: { roles: ['DIRECTIVO'] },
        loadComponent: () =>
          import('./pages/dashboard/directivo/directivo-dashboard.component').then(
            m => m.DirectivoDashboardComponent,
          ),
        title: 'Green Campus — Panel Directivo',
      },
      {
        path: '',
        redirectTo: 'tecnico',
        pathMatch: 'full',
      },
    ],
  },

  {
    path: 'profile',
    canActivate: [authGuard],
    children: [
      {
        path: '',
        loadComponent: () =>
          import('./pages/profile/profile.component').then(m => m.ProfileComponent),
        title: 'Green Campus — Mi Perfil',
      },
      {
        path: 'edit',
        loadComponent: () =>
          import('./pages/profile/edit-profile/edit-profile.component').then(
            m => m.EditProfileComponent,
          ),
        title: 'Green Campus — Editar Perfil',
      },
    ],
  },

  {
    path: 'notifications',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./pages/notifications/notifications.component').then(m => m.NotificationsComponent),
    title: 'Green Campus — Notificaciones',
  },

  {
    path: 'devices',
    canActivate: [authGuard],
    children: [
      {
        path: '',
        loadComponent: () =>
          import('./pages/dashboard/technical/device-id-search/device-id-search.component').then(
            m => m.DeviceIdSearchComponent,
          ),
        title: 'Green Campus — Buscar Dispositivo',
      },
      {
        path: ':id',
        loadComponent: () =>
          import('./pages/dashboard/technical/sensor-detail/sensor-detail.component').then(
            m => m.SensorDetailComponent,
          ),
        title: 'Green Campus — Detalle del Sensor',
      },
    ],
  },

  // Catch-all
  {
    path: '**',
    redirectTo: 'login',
  },
];
