-- CMake build integration for LazyVim
-- Since cmake-tools.nvim has dependencies, we'll use a simpler approach with custom commands

return {
  -- Optional: Add cmake support via treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "cmake" })
      end
    end,
  },
}
