module.exports = {
  content: [
    "./index.html",
    "./js/**/*.js"
  ],
  theme: {
    extend: {
      colors: {
        'pvp': '#FF0000',
        'pve': '#0000FF'
      }
    }
  },
  plugins: [
    require('daisyui')
  ],
  daisyui: {
    themes: ["dark"]
  }
} 