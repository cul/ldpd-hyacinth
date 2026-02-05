import { http, HttpResponse } from 'msw';
import { db } from '../db';

const BASE_URL = '/api/v2';

// Track the currently "logged in" user for tests
let authenticatedUserUid: string | null = null;

export const setAuthenticatedUser = (uid: string | null) => {
  authenticatedUserUid = uid;
};

export const getAuthenticatedUser = () => {
  if (!authenticatedUserUid) return null;
  return db.user.findFirst((user) => user.uid === authenticatedUserUid);
};

export const usersHandlers = [
  // GET /api/v2/users/_self - Get current authenticated user
  http.get(`${BASE_URL}/users/_self`, () => {
    const user = getAuthenticatedUser();

    if (!user) {
      return HttpResponse.json(
        { user: null },
        { status: 200 }
      );
    }

    return HttpResponse.json({ user });
  }),

  // GET /api/v2/users - List all users (sorted by uid ascending)
  http.get(`${BASE_URL}/users`, () => {
    const users = db.user.getAll().sort((a, b) => a.uid.localeCompare(b.uid));
    return HttpResponse.json({ users });
  }),

  // GET /api/v2/users/:uid - Get user by UID
  http.get(`${BASE_URL}/users/:uid`, ({ params }) => {
    const { uid } = params;
    const user = db.user.findFirst((u) => u.uid === uid);

    if (!user) {
      return HttpResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    return HttpResponse.json({ user });
  }),

  // PATCH /api/v2/users/:uid - Update user
  http.patch(`${BASE_URL}/users/:uid`, async ({ params, request }) => {
    const { uid } = params;
    const updates = await request.json();

    const user = db.user.update(uid as string, updates as Record<string, unknown>);

    if (!user) {
      return HttpResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    return HttpResponse.json({ user });
  }),

  // POST /api/v2/users - Create user
  http.post(`${BASE_URL}/users`, async ({ request }) => {
    const userData = await request.json();
    const user = db.user.create(userData as Parameters<typeof db.user.create>[0]);
    return HttpResponse.json({ user }, { status: 201 });
  }),
];
