return {
  -- Disable flash.nvim to avoid conflicts
  { "folke/flash.nvim", enabled = false },

  -- Enable easy-motion
  {
    "easymotion/vim-easymotion",
    keys = {
      { "<leader><leader>", desc = "EasyMotion prefix" },
    },
  },
}
