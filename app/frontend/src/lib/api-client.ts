const BASE_URL = '/api/v2';

export type ApiErrorResponse = {
  errors?: Record<string, string[]>;
  error?: string;
  message?: string;
  [key: string]: unknown;
};

// Error thrown for any non-2xx response. Carries the HTTP status
// and the parsed JSON body
export class ApiError extends Error {
  readonly status: number;
  readonly response: ApiErrorResponse | null;

  constructor(status: number, statusText: string, response: ApiErrorResponse | null) {
    super(response?.message ?? response?.error ?? statusText);
    this.name = 'ApiError';
    this.status = status;
    this.response = response;
  }
}

async function request<T>(endpoint: string, options?: RequestInit): Promise<T> {
  // When uploading files, the body will be a FormData instance, which automatically sets the correct Content-Type header.
  const isFormData = options?.body instanceof FormData;

  const config: RequestInit = {
    ...options,
    headers: {
      ...(isFormData ? {} : { 'Content-Type': 'application/json' }),
      Accept: 'application/json',
      ...options?.headers,
    },
    credentials: 'include',
  };

  const response = await fetch(`${BASE_URL}${endpoint}`, config);

  if (!response.ok) {
    const errorData: ApiErrorResponse | null = await response.json().catch(() => null);
    throw new ApiError(response.status, response.statusText, errorData);
  }

  // Handle cases where the response has no content (like delete operations)
  if (response.status === 204 || response.headers.get('Content-Length') === '0') {
    return {} as T;
  }

  return response.json();
}

export const api = {
  get: <T>(endpoint: string) => request<T>(endpoint, { method: 'GET' }),

  post: <T>(endpoint: string, data?: unknown) =>
    request<T>(endpoint, {
      method: 'POST',
      body: data instanceof FormData ? data : JSON.stringify(data),
    }),

  put: <T>(endpoint: string, data?: unknown) =>
    request<T>(endpoint, {
      method: 'PUT',
      body: JSON.stringify(data),
    }),

  patch: <T>(endpoint: string, data?: unknown) =>
    request<T>(endpoint, {
      method: 'PATCH',
      body: JSON.stringify(data),
    }),

  delete: <T>(endpoint: string) => request<T>(endpoint, { method: 'DELETE' }),
};
