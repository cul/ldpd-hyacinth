import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';
import globals from 'globals';

export default tseslint.config(
  {
    ignores: ['node_modules/**', 'public/**', 'tmp/**', 'log/**', 'vendor/**']
  },
    js.configs.recommended,  
    {
      files: ['**/*.js'],
      // JavaScript files with browser globals to allow for console, window, etc.
      languageOptions: {
        globals: {
          ...globals.browser,
        },
    },
  },
  // TypeScript recommended rules
  ...tseslint.configs.recommended,
  // React configuration
  {
    files: ['**/*.{ts,tsx}'],
    plugins: {
      react,
      'react-hooks': reactHooks,
    },
    settings: {
      react: {
        version: 'detect',
      },
    },
    rules: {
      // React recommended rules
      ...react.configs.recommended.rules,
      ...react.configs['jsx-runtime'].rules,
      // React Hooks rules
      ...reactHooks.configs.recommended.rules,
      // Custom adjustments
      '@typescript-eslint/no-unused-vars': 'warn',
      'react/prop-types': 'off',
    },
  },
  // Disable incompatible-library warnings for TanStack Table components
  // https://github.com/facebook/react/issues/33057
  {
    files: ['**/table-builder.tsx', '**/project-permissions-table.tsx'],
    rules: {
      'react-hooks/incompatible-library': 'off',
    },
  }
);