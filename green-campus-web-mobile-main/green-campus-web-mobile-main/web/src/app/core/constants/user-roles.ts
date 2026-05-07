export const USER_ROLES = {
  TECNICO: 'TECNICO',
  SERVICIOS_GENERALES: 'SERVICIOS_GENERALES',
  DIRECTIVO: 'DIRECTIVO',
} as const;

export type UserRole = (typeof USER_ROLES)[keyof typeof USER_ROLES];

export const ROLE_LABELS: Record<string, string> = {
  TECNICO: 'Técnico',
  SERVICIOS_GENERALES: 'Servicios Generales',
  DIRECTIVO: 'Directivo',
};

export const ROLE_DASHBOARD_ROUTES: Record<string, string> = {
  TECNICO: '/dashboard/tecnico',
  SERVICIOS_GENERALES: '/dashboard/servicios',
  DIRECTIVO: '/dashboard/directivo',
};
