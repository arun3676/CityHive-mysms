import { Component, OnInit, inject, signal } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { interval } from 'rxjs';
import { FormsModule } from '@angular/forms';
import { DatePipe } from '@angular/common';
import { MessageService, Message } from './message.service';
import { AuthService } from './auth.service';

@Component({
  selector: 'app-root',
  imports: [FormsModule, DatePipe],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App implements OnInit {
  private messages$ = inject(MessageService);
  private auth = inject(AuthService);

  readonly maxLength = 250;

  user = this.auth.currentUser;

  authUsername = '';
  authPassword = '';
  authMode = signal<'login' | 'signup'>('login');
  authError = signal<string | null>(null);

  to = '';
  body = '';
  messages = signal<Message[]>([]);
  sending = signal(false);
  error = signal<string | null>(null);

  constructor() {
    interval(8000)
      .pipe(takeUntilDestroyed())
      .subscribe(() => {
        if (this.user()) this.loadMessages();
      });
  }

  ngOnInit(): void {
    this.auth.me().subscribe({
      next: () => {
        if (this.user()) this.loadMessages();
      },
      error: () => {},
    });
  }

  submitAuth(): void {
    const username = this.authUsername.trim();
    const password = this.authPassword;
    if (!username || !password) {
      this.authError.set('Username and password are required.');
      return;
    }
    this.authError.set(null);

    const op =
      this.authMode() === 'login'
        ? this.auth.login(username, password)
        : this.auth.signup(username, password);

    op.subscribe({
      next: () => {
        this.authPassword = '';
        this.loadMessages();
      },
      error: (err) => {
        const apiErrors = err?.error?.errors;
        this.authError.set(
          Array.isArray(apiErrors) ? apiErrors.join(', ') : 'Authentication failed.',
        );
      },
    });
  }

  toggleMode(): void {
    this.authMode.set(this.authMode() === 'login' ? 'signup' : 'login');
    this.authError.set(null);
    this.authUsername = '';
    this.authPassword = '';
  }

  logout(): void {
    this.auth.logout().subscribe(() => {
      this.messages.set([]);
    });
  }

  loadMessages(): void {
    this.messages$.list().subscribe({
      next: (msgs) => this.messages.set(msgs),
      error: () => this.error.set('Could not load messages.'),
    });
  }

  send(): void {
    const to = this.to.trim();
    const body = this.body.trim();
    if (!to || !body) {
      this.error.set('Both a phone number and a message are required.');
      return;
    }

    this.sending.set(true);
    this.error.set(null);

    this.messages$.send(to, body).subscribe({
      next: () => {
        this.clear();
        this.sending.set(false);
        this.loadMessages();
      },
      error: (err) => {
        this.sending.set(false);
        const apiErrors = err?.error?.errors;
        this.error.set(
          Array.isArray(apiErrors) ? apiErrors.join(', ') : 'Failed to send message.',
        );
      },
    });
  }

  clear(): void {
    this.to = '';
    this.body = '';
    this.error.set(null);
  }
}
