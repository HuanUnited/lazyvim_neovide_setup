return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              pythonPath = vim.fn.getcwd() .. "/venv/bin/python",
              analysis = {
                typeCheckingMode = "basic",
                extraPaths = { vim.fn.getcwd() .. "/src" },
              },
            },
          },
        },
      },
    },
  },
}
