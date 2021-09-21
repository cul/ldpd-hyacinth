const appPage = (relativePath) => `http://localhost:4444${relativePath}`;

describe('/', () => {
  beforeEach(async () => {
    await page.goto(appPage('/'));
  });

  it('should redirect to /ui/v1', async () => {
    await expect(page.url()).toEqual(appPage('/ui/v1'));
  });
});

describe('/ui/v1', () => {
  beforeEach(async () => {
    await page.goto(appPage('/ui/v1'));
  });

  it('should find the app name', async () => {
    await expect(page).toMatch('Hyacinth');
  });
});
