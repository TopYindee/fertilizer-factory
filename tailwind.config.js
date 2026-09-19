/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        burgundy: {
          50: '#fdf8f8',
          100: '#f8edee',
          600: '#6b1d2f',
          700: '#541624',
          800: '#3d101a',
        }
      }
    },
  },
  plugins: [],
}
