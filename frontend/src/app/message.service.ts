import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

/** Shape of a message as returned by the Rails API (see Message#as_json). */
export interface Message {
  id: string;
  to: string;
  from: string | null;
  body: string;
  status: string;
  twilio_sid: string | null;
  error_code?: string | null;
  created_at: string;
}

@Injectable({ providedIn: 'root' })
export class MessageService {
  private http = inject(HttpClient);
  private readonly baseUrl = '/api/messages';

  /**
   * withCredentials: true makes the browser send/receive the session cookie.
   * In dev the Angular proxy makes this same-origin; in prod (cross-origin) it
   * is required for the cookie to travel at all.
   */
  list(): Observable<Message[]> {
    return this.http.get<Message[]>(this.baseUrl, { withCredentials: true });
  }

  send(to: string, body: string): Observable<Message> {
    // Wrapped under `message` to match Rails' params.require(:message).
    return this.http.post<Message>(
      this.baseUrl,
      { message: { to, body } },
      { withCredentials: true },
    );
  }
}
