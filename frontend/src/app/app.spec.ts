import { TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import {
  provideHttpClientTesting,
  HttpTestingController,
} from '@angular/common/http/testing';
import { App } from './app';

describe('App', () => {
  let httpMock: HttpTestingController;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [App],
      providers: [provideHttpClient(), provideHttpClientTesting()],
    }).compileComponents();
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => httpMock.verify());

  it('checks the session on init and shows the login form when logged out', () => {
    const fixture = TestBed.createComponent(App);
    fixture.detectChanges(); // ngOnInit -> auth.me()

    const meReq = httpMock.expectOne('/api/me');
    expect(meReq.request.method).toBe('GET');
    meReq.flush({ user: null });
    fixture.detectChanges();

    // No messages request while logged out.
    const h1: HTMLElement = fixture.nativeElement.querySelector('h1');
    expect(h1.textContent).toContain('MySMS Messenger');
    const submitText = fixture.nativeElement.textContent;
    expect(submitText).toContain('Log in');
  });

  it('loads messages when the session is already authenticated', () => {
    const fixture = TestBed.createComponent(App);
    fixture.detectChanges();

    httpMock.expectOne('/api/me').flush({ user: { id: '1', username: 'alice' } });
    fixture.detectChanges();

    const listReq = httpMock.expectOne('/api/messages');
    expect(listReq.request.method).toBe('GET');
    listReq.flush([]);
  });
});
