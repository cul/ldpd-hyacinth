import { http, HttpResponse, JsonBodyType } from 'msw';
import { setupServer } from 'msw/node';

export const server = setupServer();

type HttpMethod = 'get' | 'post' | 'put' | 'delete' | 'patch';

// Register a mock API response for a single endpoint. Call once per endpoint per test.
// Overrides are cleared automatically by `server.resetHandlers()` in the global `afterEach`.
export const mockApi = (
  method: HttpMethod,
  path: string,
  body: JsonBodyType,
  status = 200,
) => {
  server.use(
    http[method](`api/v2${path}`, () =>
      HttpResponse.json(body, { status }),
    ),
  );
};