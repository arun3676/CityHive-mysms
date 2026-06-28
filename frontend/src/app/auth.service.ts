import { Injectable, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';

export interface User {
  id: string;
  username: string;
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private http = inject(HttpClient);

  readonly currentUser = signal<User | null>(null);

  me(): Observable<{ user: User | null }> {
    return this.http
      .get<{ user: User | null }>('/api/me', { withCredentials: true })
      .pipe(tap((r) => this.currentUser.set(r.user)));
  }

  login(username: string, password: string): Observable<{ user: User }> {
    return this.http
      .post<{ user: User }>('/api/login', { user: { username, password } }, { withCredentials: true })
      .pipe(tap((r) => this.currentUser.set(r.user)));
  }

  signup(username: string, password: string): Observable<{ user: User }> {
    return this.http
      .post<{ user: User }>('/api/signup', { user: { username, password } }, { withCredentials: true })
      .pipe(tap((r) => this.currentUser.set(r.user)));
  }

  logout(): Observable<unknown> {
    return this.http
      .delete('/api/logout', { withCredentials: true })
      .pipe(tap(() => this.currentUser.set(null)));
  }
}
