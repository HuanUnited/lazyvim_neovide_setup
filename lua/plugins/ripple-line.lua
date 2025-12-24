return {
  {
    dir = vim.fn.stdpath("config") .. "/local/ripple-line.nvim",
    name = "ripple-line.nvim",
    event = "VeryLazy",
    opts = {
      -- put your config overrides here (or leave empty for defaults)
      -- extra_column = true,
    },
    config = function(_, opts)
      require("ripple-line").setup(opts)
    end,
  },
}
