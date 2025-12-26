return {
  "dgagn/diagflow.nvim",
  event = "LspAttach", -- Only load when an LSP is active
  opts = {
    scope = "line", -- Options: 'cursor' (default) or 'line'
    enable = true,
    max_width = 60,
    severity_colors = {
      error = "DiagnosticFloatingError",
      warning = "DiagnosticFloatingWarn",
      info = "DiagnosticFloatingInfo",
      hint = "DiagnosticFloatingHint",
    },
  },
}
