/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        'tech-dark': '#0a0f1f',
        'tech-light': '#1a1f2f',
        'neon-blue': '#00f3ff',
        'neon-pink': '#ff00e6',
        'neon-green': '#00ff9d',
      },
      fontFamily: {
        'mono': ['Fira Code', 'monospace'],
      },
      animation: {
        'glow': 'glow 2s ease-in-out infinite alternate',
      },
      keyframes: {
        glow: {
          '0%': { textShadow: '0 0 5px #00f3ff' },
          '100%': { textShadow: '0 0 20px #ff00e6' },
        }
      }
    },
  },
  plugins: [],
}
