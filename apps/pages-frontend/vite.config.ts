import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// Sovereign Proof-of-AI Frontend Configuration
// Copyright (C) 2024 Andrew Lee Cruz - Creator of the Universe

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  define: {
    'process.env': {},
    global: 'globalThis',
  },
  server: {
    port: 3000,
    host: true,
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    minify: 'esbuild',
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          blockchain: ['ethers', 'web3'],
          ui: ['@mui/material', '@emotion/react', '@emotion/styled'],
          three: ['three', '@react-three/fiber', '@react-three/drei']
        }
      }
    }
  },
  optimizeDeps: {
    include: ['react', 'react-dom', 'ethers', 'web3']
  },
  resolve: {
    alias: {
      '@': '/src'
    }
  }
})