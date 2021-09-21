module.exports = {
  testRegex: './*\\.e2e-spec\\.js$', // Note: This is a different extension than the non-e2e tests
  preset: 'jest-puppeteer',
  roots: [
    'spec/javascript/e2e',
  ],
  // For e2e tests, having multiple workers can actually end up slowing tests down, so we'll set
  // maxWorkers to 1.  This is the same effect as the --runInBand command line argument.
  maxWorkers: 1,
  setupFilesAfterEnv: [
    '<rootDir>/spec/javascript/jest-e2e-setup.js',
  ],
};
