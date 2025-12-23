return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        window = {
          mappings = {
            ["S-Enter"] = "set_root", -- cd into folder (changes cwd)
            ["."] = "set_root", -- Default: also cd
            ["<bs>"] = "navigate_up", -- Go up directory
          },
        },
      },
    },
  },
}
