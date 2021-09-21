const appPage = (relativePath) => `http://localhost:4444${relativePath}`;

// TODO: determine whether the beforeEach extended timeouts are still needed if we make a
// first-time request to the app before running tests.

describe('/', () => {
  beforeEach(async () => {
    await page.goto(appPage('/'));
  }, (20 * 1000));

  it('should redirect to /ui/v1', async () => {
    await expect(page.url()).toEqual(appPage('/ui/v1'));
  });
});

describe('/ui/v1', () => {
  beforeEach(async () => {
    await page.goto(appPage('/ui/v1'));
  }, (20 * 1000));

  it('should find the app name', async () => {
    await expect(page).toMatch('Hyacinth');
  });
});
