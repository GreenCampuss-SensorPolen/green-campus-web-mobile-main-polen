export interface HourlyPrediction {
  hour: string;               // Ej: "08:00"
  co2: number;                // Valor de CO2 predicho para esa hora
  temperature?: number;       // Valor de temperatura (opcional de momento hasta que lo añadamos)
}

export interface DailyPrediction {
  target_date: string;         // Ej: "2026-05-18"
  day_type: string;           // Ej: "Día lectivo" o "Fin de semana"
  daily_average: number;      // Media de CO2 del día
  temperature_average?: number; // Media de temperatura del día (opcional de momento)
  hourly_predictions: HourlyPrediction[]; // Array con las 24 horas del día
}

export interface AIPredictionResponse {
  report_type: string;        // Ej: "Pronóstico a 7 días"
  week_predictions: DailyPrediction[];
}