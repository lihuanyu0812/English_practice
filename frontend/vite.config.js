import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

const backendPort = process.env.BACKEND_PORT || '8016';

export default defineConfig({
  plugins: [vue()],
  server: {
    host: process.env.FRONTEND_HOST || '0.0.0.0',
    port: Number(process.env.FRONTEND_PORT || 9016),
    proxy: {
      '/api': {
        target: `http://127.0.0.1:${backendPort}`,
        changeOrigin: true
      }
    }
  }
});
