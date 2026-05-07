import { inject } from '@angular/core';
import { CanActivateFn, Router, ActivatedRouteSnapshot } from '@angular/router';
import { TokenStorageService } from '../data/services/token-storage.service';

export const roleGuard: CanActivateFn = (route: ActivatedRouteSnapshot) => {
  const tokenStorage = inject(TokenStorageService);
  const router = inject(Router);

  const allowedRoles: string[] = route.data['roles'] ?? [];
  const user = tokenStorage.currentUser;

  if (!user) {
    return router.createUrlTree(['/login']);
  }

  if (allowedRoles.length === 0 || allowedRoles.includes(user.role)) {
    return true;
  }

  // Redirect to appropriate dashboard
  const rolePaths: Record<string, string> = {
    TECNICO: '/dashboard/tecnico',
    SERVICIOS_GENERALES: '/dashboard/servicios',
    DIRECTIVO: '/dashboard/directivo',
  };
  return router.createUrlTree([rolePaths[user.role] ?? '/login']);
};
