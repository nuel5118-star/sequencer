/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['DM Sans', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
        display: ['Syne', 'sans-serif'],
      },
      colors: {
        base: {
          950: '#080810',
          900: '#0d0d1a',
          800: '#12122a',
          700: '#1a1a35',
          600: '#22224a',
          500: '#2e2e60',
        },
        accent: {
          DEFAULT: '#7c6af7',
          hover: '#9685ff',
          dim: '#3d3478',
        },
        emerald: { 400: '#34d399', 500: '#10b981' },
        rose: { 400: '#fb7185', 500: '#f43f5e' },
        sky: { 400: '#38bdf8', 500: '#0ea5e9' },
        amber: { 400: '#fbbf24', 500: '#f59e0b' },
      }
    }
  },
  plugins: []
}
