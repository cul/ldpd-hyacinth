/// <reference types="vitest/config" />
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import path from 'path'

export default defineConfig({
  plugins: [
    RubyPlugin(),
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './app/frontend/src')
    }
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/testing/setup.ts',
    root: './app/frontend',
  },
})
