export interface TelemetryData {
  temperature?: number;
  humidity?: number;
  co2?: number;
  energy?: number;
}

export interface IotNode {
  id: string;
  name: string;
  location: string;
  type: string;       // 'Raspberry Pi', 'Arduino', sensor types
  status: string;     // 'ONLINE', 'STANDBY', 'OFFLINE'
  battery: number;    // 0-100
  edificio: string;
  planta: string;
  rssi?: number;
  uptime?: number;
  linkQuality?: number;
  lastTelemetry?: TelemetryData;
}

export interface MonthlyReading {
  day: string;   // API returns strings: "5", "13"...
  value: string; // API returns strings: "22.90", "25.50"...
}

export interface TechnicalSummary {
  totalNodes: number;
  onlineNodes: number;
  alertNodes: number;
}
