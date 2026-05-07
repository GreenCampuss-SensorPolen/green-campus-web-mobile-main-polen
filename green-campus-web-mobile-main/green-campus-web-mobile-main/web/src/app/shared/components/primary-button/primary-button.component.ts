import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-primary-button',
  standalone: true,
  imports: [CommonModule],
  template: `
    <button
      [type]="type"
      [disabled]="loading || disabled"
      [class]="buttonClass"
      class="w-full font-semibold py-3 px-6 rounded-lg transition-colors duration-200
             flex items-center justify-center gap-2 focus:outline-none focus:ring-2
             focus:ring-offset-2 focus:ring-accent-green"
      [ngClass]="{
        'bg-accent-green text-white hover:bg-green-600 active:bg-green-700 focus:ring-accent-green': !outline,
        'bg-transparent border-2 border-accent-green text-accent-green hover:bg-accent-green-bg': outline,
        'opacity-50 cursor-not-allowed': loading || disabled
      }"
    >
      @if (loading) {
        <svg class="animate-spin h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
          </path>
        </svg>
      }
      <span>{{ loading ? loadingText : label }}</span>
    </button>
  `,
})
export class PrimaryButtonComponent {
  @Input() label = 'Submit';
  @Input() loadingText = 'Cargando...';
  @Input() loading = false;
  @Input() disabled = false;
  @Input() outline = false;
  @Input() type: 'button' | 'submit' | 'reset' = 'submit';
  @Input() buttonClass = '';
}
