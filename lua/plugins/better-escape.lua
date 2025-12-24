return {
  "max397574/better-escape.nvim",
  event = "InsertEnter",
  config = function()
    require("better_escape").setup({
      mapping = { "jj" }, -- maps jj to escape
      timeout = 150, -- ms to wait for second key
    })
  end,
}
