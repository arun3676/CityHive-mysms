import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

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

  list(): Observable<Message[]> {
    return this.http.get<Message[]>(this.baseUrl, { withCredentials: true });
  }

  send(to: string, body: string): Observable<Message> {
    return this.http.post<Message>(
      this.baseUrl,
      { message: { to, body } },
      { withCredentials: true },
    );
  }
}
