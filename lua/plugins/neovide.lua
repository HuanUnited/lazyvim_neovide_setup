return {
  {
    "neovide/neovide",
    opts = function()
      vim.g.neovide_opacity = 0.9
      vim.g.neovide_normal_opacity = 0.9
      vim.g.neovide_cursor_vfx_mode = "railgun"
      vim.g.neovide_floating_blur_amount_x = 2.0
      vim.g.neovide_floating_blur_amount_y = 2.0
    end,
    config = function()
      if vim.g.neovide then
        -- Vimscript F11 toggle (works in WSL2 + LazyVim)
        vim.keymap.set("n", "<F11>", function()
          local current = vim.g.neovide_fullscreen
          vim.g.neovide_fullscreen = not current
        end, { noremap = true, silent = false }) -- silent=false for debug
      end
    end,
  },
}
