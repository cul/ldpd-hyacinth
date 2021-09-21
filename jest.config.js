module.exports = {
  testRegex: './*\\.spec\\.js$', // Note: This is a different extension than the e2e tests
  roots: [
    // Unit tests should be put in files that are adjacent to the module being tested
    'app/javascript/src',
    // Integration tests that aren't specific to a module should be put in spec/javascript
    'spec/javascript',
  ],
  setupFilesAfterEnv: [
    // Many configurations in here are needed for component testing with React Testing Library
    '<rootDir>/spec/javascript/jest-setup.js',
  ],
  moduleNameMapper: {
    // Needed for component testing with React Testing Library
    'ace-builds': '<rootDir>/node_modules/ace-builds',
  },
};
