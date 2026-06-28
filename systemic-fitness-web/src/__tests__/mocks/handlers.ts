import { http, HttpResponse } from 'msw';

// MSW handlers for API mocking in tests
export const handlers = [
  // Auth
  http.post('http://localhost:8080/api/auth/login', () => {
    return HttpResponse.json({
      success: true,
      data: {
        user: {
          id: 'user-1',
          email: 'test@example.com',
          full_name: 'Test User',
          role: 'admin',
          status: 'active',
        },
        access_token: 'mock-access-token',
        refresh_token: 'mock-refresh-token',
        expires_at: new Date(Date.now() + 900000).toISOString(),
      },
      message: 'Login successful',
    });
  }),

  // Users list
  http.get('http://localhost:8080/api/users', () => {
    return HttpResponse.json({
      success: true,
      data: [
        { id: 'u1', email: 'admin@systemicfitness.com', full_name: 'Admin User', role: 'admin', status: 'active' },
        { id: 'u2', email: 'trainer@systemicfitness.com', full_name: 'Trainer One', role: 'trainer', status: 'active' },
        { id: 'u3', email: 'client@systemicfitness.com', full_name: 'Client One', role: 'client', status: 'active' },
      ],
      meta: { page: 1, limit: 20, total: 3, total_pages: 1 },
    });
  }),

  // Conversations
  http.get('http://localhost:8080/api/messages/conversations', () => {
    return HttpResponse.json({
      success: true,
      data: [
        {
          id: 'conv-1',
          type: 'direct',
          name: 'Coach Alex',
          unread_count: 2,
          member_count: 2,
          last_message: {
            id: 'msg-1',
            content: 'Great workout today!',
            sender_name: 'Coach Alex',
            created_at: new Date().toISOString(),
          },
        },
      ],
      meta: { page: 1, limit: 50, total: 1, total_pages: 1 },
    });
  }),

  // Auth/me
  http.get('http://localhost:8080/api/auth/me', () => {
    return HttpResponse.json({
      success: true,
      data: {
        user: {
          id: 'user-1',
          email: 'test@example.com',
          full_name: 'Test User',
          role: 'admin',
          status: 'active',
        },
        profile: null,
        stats: null,
      },
    });
  }),
];
