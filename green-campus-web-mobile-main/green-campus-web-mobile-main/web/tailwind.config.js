/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/**/*.{html,ts}',
  ],
  theme: {
    extend: {
      colors: {
        'accent-green': '#22C55E',
        'accent-green-light': '#DCFCE7',
        'accent-green-bg': '#F0FDF4',
        'bg-page': '#FFFFFF',
        'surface': '#F8FAFC',
        'card-bg': '#FFFFFF',
        'text-primary': '#1A1A1A',
        'text-secondary': '#64748B',
        'text-muted': '#94A3B8',
        'border-color': '#E2E8F0',
        'status-online': '#22C55E',
        'status-warning': '#F59E0B',
        'status-offline': '#EF4444',
      },
      fontFamily: {
        'inter': ['Inter', 'sans-serif'],
        'mono': ['"JetBrains Mono"', 'monospace'],
      },
      borderRadius: {
        'card': '8px',
      },
      boxShadow: {
        'card': '0 1px 3px 0 rgba(0,0,0,0.1), 0 1px 2px -1px rgba(0,0,0,0.1)',
        'card-hover': '0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -2px rgba(0,0,0,0.1)',
      },
    },
  },
  plugins: [],
};
