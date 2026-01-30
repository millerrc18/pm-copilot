const defaultTheme = require("tailwindcss/defaultTheme")

module.exports = {
  content: [
    "./app/views/**/*.erb",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js"
  ],
  theme: {
    extend: {
      colors: {
        "dark-bg": "var(--dark-bg)",
        "dark-panel": "var(--dark-panel)",
        "dark-panel-strong": "var(--dark-panel-strong)",
        "light-text": "var(--light-text)",
        "accent-red": "var(--accent-red)",
        "gray-muted": "var(--gray-muted)"
      },
      boxShadow: {
        panel: "0 20px 45px rgba(0, 0, 0, 0.45)",
        glow: "0 0 0 1px rgba(224, 100, 105, 0.4), 0 0 18px rgba(224, 100, 105, 0.25)"
      },
      borderRadius: {
        xl: "18px",
        "2xl": "22px"
      },
      fontFamily: {
        sans: ["Inter", ...defaultTheme.fontFamily.sans]
      }
    }
  },
  plugins: []
}
