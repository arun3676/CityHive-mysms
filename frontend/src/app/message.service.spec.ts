import { TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import {
  provideHttpClientTesting,
  HttpTestingController,
} from '@angular/common/http/testing';
import { MessageService } from './message.service';

describe('MessageService', () => {
  let service: MessageService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    service = TestBed.inject(MessageService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => httpMock.verify());

  it('list() does GET /api/messages with credentials', () => {
    service.list().subscribe();

    const req = httpMock.expectOne('/api/messages');
    expect(req.request.method).toBe('GET');
    expect(req.request.withCredentials).toBe(true);
    req.flush([]);
  });

  it('send() POSTs the payload wrapped under "message"', () => {
    service.send('+15551234567', 'hello').subscribe();

    const req = httpMock.expectOne('/api/messages');
    expect(req.request.method).toBe('POST');
    expect(req.request.body).toEqual({
      message: { to: '+15551234567', body: 'hello' },
    });
    expect(req.request.withCredentials).toBe(true);
    req.flush({});
  });
});
