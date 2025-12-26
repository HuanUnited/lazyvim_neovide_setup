return {
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    ft = "python", -- Only load when opening a Python file
    cmd = "VenvSelect",
    opts = {
      -- Set to true to see a notification when a venv is activated
      notify_user_on_venv_activation = true, 
    },
    keys = {
      -- Keybinding to open the selector
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" },
    },
  },
}