return {
  -- Configure nvim-lint for additional linters
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        python = {
          "mypy", -- Strict type checking
          "vulture", -- Dead code detection
          "bandit", -- Security checks
        },
      },
    },
  },

  -- Optional: Slow linters only on save
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- Run mypy only on save (it's slow)
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        pattern = { "*.py" },
        callback = function()
          require("lint").try_lint("mypy")
        end,
      })
      return opts
    end,
  },
}
