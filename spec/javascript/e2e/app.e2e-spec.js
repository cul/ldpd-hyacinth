const appPage = (relativePath) => `http://localhost:4444${relativePath}`;

describe('/', () => {
  // set jest timeouts to be very long for this e2e test suite
  jest.setTimeout(20 * 1000);

  // reset jest timeouts
  afterAll(() => jest.setTimeout(5 * 1000));

  beforeEach(async () => {
    await page.goto(appPage('/'));
  });

  it('should redirect to /ui/v1', async () => {
    await expect(page.url()).toEqual(appPage('/ui/v1'));
  });
});

describe('/ui/v1', () => {
  // set jest timeouts to be very long for this e2e test suite
  jest.setTimeout(20 * 1000);

  // reset jest timeouts
  afterAll(() => jest.setTimeout(5 * 1000));

  beforeEach(async () => {
    await page.goto(appPage('/ui/v1'));
  });

  it('should find the app name', async () => {
    await expect(page).toMatch('Hyacinth');
  });
});
