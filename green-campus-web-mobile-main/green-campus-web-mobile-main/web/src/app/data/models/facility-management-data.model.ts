export interface HabitabilityStats {
  averageTemp: number;
  averageHumidity: number;
  averageCo2: number;
}

export interface ZoneConfort {
  id: string;
  name: string;
  status: string;   // 'OPTIMO', 'REGULAR', 'CRITICO'
  temp: number;
  humidity: number;
}

export interface PreventiveTask {
  id: string;
  title: string;
  location: string;
  daysRemaining: number;
  priority: string;  // 'CRITICAL', 'MEDIUM', 'LOW'
}
